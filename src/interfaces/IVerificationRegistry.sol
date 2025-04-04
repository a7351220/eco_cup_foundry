// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

interface IVerificationRegistry {
    function recordVerification(address user) external;
    function canClaimReward(address user) external view returns (bool);
    function markRewardClaimed(address user) external;
    function getVerificationCount(address user) external view returns (uint32);
}
