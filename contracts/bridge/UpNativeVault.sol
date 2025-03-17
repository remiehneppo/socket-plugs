// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./Base.sol";
import "../interfaces/IConnector.sol";
import "../interfaces/INativePool.sol";

contract UpNativeVault is Base {
    INativePool public immutable nativePool;

    constructor(address nativePool_) Base(ETH_ADDRESS) {
        bridgeType = NATIVE_VAULT;
        nativePool = INativePool(nativePool_);
    }

    /**
     * @notice Bridges tokens between chains.
     * @dev This function allows bridging tokens between different chains.
     * @param receiver_ The address to receive the bridged tokens.
     * @param amount_ The amount of tokens to bridge.
     * @param msgGasLimit_ The gas limit for the execution of the bridging process.
     * @param connector_ The address of the connector contract responsible for the bridge.
     * @param extraData_ The extra data passed to hook functions.
     * @param options_ Additional options for the bridging process.
     */
    function bridge(
        address receiver_,
        uint256 amount_,
        uint256 msgGasLimit_,
        address connector_,
        bytes calldata extraData_,
        bytes calldata options_
    ) external payable nonReentrant {
        (
            TransferInfo memory transferInfo,
            bytes memory postHookData
        ) = _beforeBridge(
                connector_,
                TransferInfo(receiver_, amount_, extraData_)
            );

        _receiveTokens(transferInfo.amount);

        _afterBridge(
            msgGasLimit_,
            connector_,
            options_,
            postHookData,
            transferInfo
        );
    }

    /**
     * @notice Receives inbound tokens from another chain.
     * @dev This function is used to receive tokens from another chain.
     * @param siblingChainSlug_ The identifier of the sibling chain.
     * @param payload_ The payload containing the inbound tokens.
     */
    function receiveInbound(
        uint32 siblingChainSlug_,
        bytes memory payload_
    ) external payable override nonReentrant {
        (
            address receiver,
            uint256 unlockAmount,
            bytes32 messageId,
            bytes memory extraData
        ) = abi.decode(payload_, (address, uint256, bytes32, bytes));

        TransferInfo memory transferInfo = TransferInfo(
            receiver,
            unlockAmount,
            extraData
        );

        bytes memory postHookData;
        (postHookData, transferInfo) = _beforeMint(
            siblingChainSlug_,
            transferInfo
        );

        _transferTokens(transferInfo.receiver, transferInfo.amount);

        _afterMint(unlockAmount, messageId, postHookData, transferInfo);
    }

    /**
     * @notice Retry a failed transaction.
     * @dev This function allows retrying a failed transaction sent through a connector.
     * @param connector_ The address of the connector contract responsible for the failed transaction.
     * @param messageId_ The unique identifier of the failed transaction.
     */
    function retry(
        address connector_,
        bytes32 messageId_
    ) external nonReentrant {
        (
            bytes memory postHookData,
            TransferInfo memory transferInfo
        ) = _beforeRetry(connector_, messageId_);
        _transferTokens(transferInfo.receiver, transferInfo.amount);

        _afterRetry(connector_, messageId_, postHookData);
    }

    function _transferTokens(address receiver_, uint256 amount_) internal {
        if (amount_ == 0) return;
        nativePool.transfer(receiver_, amount_);
    }

    function _receiveTokens(uint256 amount_) internal {
        if (amount_ == 0) return;
        nativePool.deposit{value: amount_}(amount_);
    }
}
