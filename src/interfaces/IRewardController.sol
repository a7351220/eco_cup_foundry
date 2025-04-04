// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

interface IRewardController {
    function calculateReward(address user) external view returns (uint256);
    function distributeReward(address user) external returns (uint256);
}
