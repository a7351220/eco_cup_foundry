// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title VerificationRegistry
 * @notice Manages user verification records and verifier permissions
 */
contract VerificationRegistry is AccessControl {
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    uint256 public constant REQUIRED_DAILY_VERIFICATIONS = 3;

    struct DailyVerification {
        uint256 date; // 日期戳 (天)
        uint32 count; // 当日验证次数
        bool rewardClaimed; // 是否已领取奖励
    }

    mapping(address => DailyVerification) public userVerifications;

    event VerificationRecorded(address indexed user, uint256 date, uint32 count);
    event RewardClaimed(address indexed user, uint256 date);
    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);

    /**
     * @notice Constructor sets contract deployer as admin and verifier
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VERIFIER_ROLE, msg.sender);
    }

    /**
     * @notice 記錄用戶完成驗證
     * @param user 完成驗證的用戶地址
     */
    function recordVerification(address user) external onlyRole(VERIFIER_ROLE) {
        uint256 today = block.timestamp / 1 days;

        // 如果是新的一天，重置验证计数
        if (userVerifications[user].date < today) {
            userVerifications[user].date = today;
            userVerifications[user].count = 1;
            userVerifications[user].rewardClaimed = false;
        } else {
            // 同一天内，增加验证计数
            userVerifications[user].count += 1;
        }

        emit VerificationRecorded(user, today, userVerifications[user].count);
    }

    /**
     * @notice 檢查用戶是否可以領取獎勵
     * @param user 用戶地址
     * @return 是否可以領取獎勵
     */
    function canClaimReward(address user) external view returns (bool) {
        uint256 today = block.timestamp / 1 days;
        DailyVerification memory verification = userVerifications[user];

        return verification.date == today && verification.count >= REQUIRED_DAILY_VERIFICATIONS
            && !verification.rewardClaimed;
    }

    /**
     * @notice 標記用戶已領取獎勵
     * @param user 用戶地址
     */
    function markRewardClaimed(address user) external onlyRole(VERIFIER_ROLE) {
        uint256 today = block.timestamp / 1 days;
        require(userVerifications[user].date == today, "Not verified today");
        require(userVerifications[user].count >= REQUIRED_DAILY_VERIFICATIONS, "Not enough verifications");
        require(!userVerifications[user].rewardClaimed, "Reward already claimed");

        userVerifications[user].rewardClaimed = true;
        emit RewardClaimed(user, today);
    }

    /**
     * @notice 獲取用戶當日驗證次數
     * @param user 用戶地址
     * @return 當日驗證次數
     */
    function getVerificationCount(address user) external view returns (uint32) {
        uint256 today = block.timestamp / 1 days;
        if (userVerifications[user].date == today) {
            return userVerifications[user].count;
        }
        return 0;
    }

    /**
     * @notice Add a new verifier
     * @param verifier Address to grant verifier role
     */
    function addVerifier(address verifier) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(verifier != address(0), "Invalid verifier address");
        _grantRole(VERIFIER_ROLE, verifier);
        emit VerifierAdded(verifier);
    }

    /**
     * @notice Remove a verifier
     * @param verifier Address to revoke verifier role
     */
    function removeVerifier(address verifier) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(verifier != address(0), "Invalid verifier address");
        _revokeRole(VERIFIER_ROLE, verifier);
        emit VerifierRemoved(verifier);
    }
}
