// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./interfaces/INativePool.sol";
import "openzeppelin-contracts/contracts/utils/structs/EnumerableSet.sol";

contract NativePool is INativePool {
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private bridges;
    address public owner;
    address public feeCollector;
    uint256 public fee;
    uint256 public feeAccumulated;

    modifier onlyOwner() {
        require(msg.sender == owner, "NativePool: only owner");
        _;
    }

    modifier onlyBridgeOrOwner() {
        require(
            msg.sender == owner || bridges.contains(msg.sender),
            "NativePool: only bridge or owner"
        );
        _;
    }

    constructor() {
        owner = msg.sender;
        feeCollector = msg.sender;
        fee = 0;
    }

    function deposit(uint256 amount) external payable {
        require(msg.value == amount, "NativePool: invalid amount");
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(
            amount <= address(this).balance,
            "NativePool: insufficient balance"
        );
        payable(owner).transfer(amount);
    }

    function transfer(address to, uint256 amount) external onlyBridgeOrOwner {
        require(
            amount <= address(this).balance,
            "NativePool: insufficient balance"
        );
        if (fee > 0) {
            uint256 feeAmount = (amount * fee) / 10000;
            feeAccumulated += feeAmount;
            amount -= feeAmount;
        }
        payable(to).transfer(amount);
    }

    function claimFee() external {
        require(msg.sender == feeCollector, "NativePool: only fee collector");
        payable(feeCollector).transfer(feeAccumulated);
        feeAccumulated = 0;
    }

    function registerBridge(address bridge) external onlyOwner {
        bridges.add(bridge);
    }

    function unregisterBridge(address bridge) external onlyOwner {
        bridges.remove(bridge);
    }

    function setFee(uint256 fee_) external onlyOwner {
        require(fee_ <= 1000, "NativePool: fee too high");
        fee = fee_;
    }

    function setFeeCollector(address feeCollector_) external onlyOwner {
        feeCollector = feeCollector_;
    }

    function remaining() external view returns (uint256) {
        return address(this).balance;
    }

    function getBridges() external view returns (address[] memory) {
        address[] memory result = new address[](bridges.length());
        for (uint256 i = 0; i < bridges.length(); i++) {
            result[i] = bridges.at(i);
        }
        return result;
    }

    function getBridgesLength() external view returns (uint256) {
        return bridges.length();
    }
}
