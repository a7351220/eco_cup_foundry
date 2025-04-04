// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

interface IStakingPool {
    function stake() external payable;
    function withdraw(uint256 amount) external;
    function getStakedAmount(address user) external view returns (uint256);
}
