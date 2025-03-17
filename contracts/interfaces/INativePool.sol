// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

interface INativePool {
    function deposit(uint256 amount) external payable;
    function withdraw(uint256 amount) external;
    function transfer(address to, uint256 amount) external;
    function remaining() external view returns (uint256);
    function feeAccumulated() external view returns (uint256);
    function fee() external view returns (uint256);
    function claimFee() external;
    function registerBridge(address bridge) external;
    function unregisterBridge(address bridge) external;
    function setFee(uint256 fee_) external;
    function setFeeCollector(address feeCollector_) external;
    function feeCollector() external view returns (address);
    function getBridges() external view returns (address[] memory);
    function getBridgesLength() external view returns (uint256);
}
