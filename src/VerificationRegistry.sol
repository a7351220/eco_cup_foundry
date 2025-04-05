// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./SelfVerification.sol";

/**
 * @title VerificationRegistry
 * @notice Manages user verification records and verifier permissions with Self identity verification
 */
contract VerificationRegistry is AccessControl {
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    uint256 public constant REQUIRED_DAILY_VERIFICATIONS = 3;

    SelfVerification public selfVerification;

    struct DailyVerification {
        uint256 date; // timestamp (day)
        uint32 count; // verification count
        bool rewardClaimed; // reward claimed
    }

    mapping(address => DailyVerification) public userVerifications;

    event VerificationRecorded(address indexed user, uint256 date, uint32 count);
    event RewardClaimed(address indexed user, uint256 date);
    event VerifierAdded(address indexed verifier);
    event VerifierRemoved(address indexed verifier);
    event SelfVerificationSet(address indexed verificationContract);

    /**
     * @notice Constructor sets contract deployer as admin and verifier
     */
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VERIFIER_ROLE, msg.sender);
    }

    /**
     * @notice set Self identity verification contract address
     * @param _selfVerification Self identity verification contract address, can be set to address(0) to disable identity verification
     */
    function setSelfVerification(address _selfVerification) external onlyRole(DEFAULT_ADMIN_ROLE) {
        // allow setting to zero address to disable identity verification functionality
        selfVerification = SelfVerification(_selfVerification);
        emit SelfVerificationSet(_selfVerification);
    }

    /**
     * @notice check if user is verified
     * @param user already verified address 
     * @return if user is verified
     */
    function isIdentityVerified(address user) public view returns (bool) {
        if (address(selfVerification) == address(0)) {
            return true;
        }
        return selfVerification.isIdentityVerified(user);
    }

    /**
     * @notice record user verification
     * @param user already verified address 
     */
    function recordVerification(address user) external onlyRole(VERIFIER_ROLE) {
        require(isIdentityVerified(user), "Identity verification required");
        
        uint256 today = block.timestamp / 1 days;

        if (userVerifications[user].date < today) {
            userVerifications[user].date = today;
            userVerifications[user].count = 1;
            userVerifications[user].rewardClaimed = false;
        } else {
            userVerifications[user].count += 1;
        }

        emit VerificationRecorded(user, today, userVerifications[user].count);
    }

    /**
     * @notice check if user can claim reward
     * @param user already verified address 
     * @return if user can claim reward
     */
    function canClaimReward(address user) external view returns (bool) {
        if (!isIdentityVerified(user)) {
            return false;
        }
        
        uint256 today = block.timestamp / 1 days;
        DailyVerification memory verification = userVerifications[user];

        return verification.date == today && verification.count >= REQUIRED_DAILY_VERIFICATIONS
            && !verification.rewardClaimed;
    }

    /**
     * @notice mark user as claimed reward
     * @param user already verified address 
     */
    function markRewardClaimed(address user) external onlyRole(VERIFIER_ROLE) {
        require(isIdentityVerified(user), "Identity verification required");
        uint256 today = block.timestamp / 1 days;
        require(userVerifications[user].date == today, "Not verified today");
        require(userVerifications[user].count >= REQUIRED_DAILY_VERIFICATIONS, "Not enough verifications");
        require(!userVerifications[user].rewardClaimed, "Reward already claimed");

        userVerifications[user].rewardClaimed = true;
        emit RewardClaimed(user, today);
    }

    /**
     * @notice get user verification count
     * @param user already verified address 
     * @return verification count
     */
    function getVerificationCount(address user) external view returns (uint32) {
        uint256 today = block.timestamp / 1 days;
        if (userVerifications[user].date == today) {
            return userVerifications[user].count;
        }
        return 0;
    }

    /**
     * @notice add a new verifier
     * @param verifier Address to grant verifier role
     */
    function addVerifier(address verifier) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(verifier != address(0), "Invalid verifier address");
        _grantRole(VERIFIER_ROLE, verifier);
        emit VerifierAdded(verifier);
    }

    /**
     * @notice remove a verifier
     * @param verifier Address to revoke verifier role
     */
    function removeVerifier(address verifier) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(verifier != address(0), "Invalid verifier address");
        _revokeRole(VERIFIER_ROLE, verifier);
        emit VerifierRemoved(verifier);
    }
}
