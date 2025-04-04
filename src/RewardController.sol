// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IEcoCupToken.sol";
import "./interfaces/IVerificationRegistry.sol";
import "./interfaces/IStakingPool.sol";

/**
 * @title RewardController
 * @notice Manages reward calculation and distribution logic
 */
contract RewardController is Ownable {
    uint256 public dailyAPR = 500; // Default 5.00% (represented with base 10000)
    IEcoCupToken public token;
    IVerificationRegistry public verificationRegistry;
    IStakingPool public stakingPool;

    // Event definitions
    event RewardDistributed(address indexed user, uint256 amount);
    event DailyAPRSet(uint256 oldValue, uint256 newValue);
    event TokenSet(address indexed tokenAddress);
    event VerificationRegistrySet(address indexed registryAddress);
    event StakingPoolSet(address indexed poolAddress);

    /**
     * @notice Constructor sets contract deployer as initial owner
     */
    constructor(address _token, address _registry) Ownable(msg.sender) {
        require(_token != address(0), "Invalid token address");
        require(_registry != address(0), "Invalid registry address");
        token = IEcoCupToken(_token);
        verificationRegistry = IVerificationRegistry(_registry);
    }

    /**
     * @notice Calculate user's available reward
     * @param user User address
     * @return Reward amount
     */
    function calculateReward(address user) public view returns (uint256) {
        // Check if reward dependencies are set
        if (address(stakingPool) == address(0) || address(verificationRegistry) == address(0)) {
            return 0;
        }

        // Check if user has completed enough verifications
        if (!verificationRegistry.canClaimReward(user)) {
            return 0;
        }

        // Get user's staked amount
        uint256 staked = stakingPool.getStakedAmount(user);
        if (staked == 0) {
            return 0;
        }

        // Calculate daily reward
        // Reward = staked amount * daily APR / 10000
        return staked * dailyAPR / 10_000;
    }

    /**
     * @notice Distribute reward to user
     * @param user User address
     * @return Distributed reward amount
     */
    function distributeReward(address user) external returns (uint256) {
        // Ensure reward dependencies are set
        require(address(token) != address(0), "Token not set");
        require(address(verificationRegistry) != address(0), "Registry not set");
        require(address(stakingPool) != address(0), "Staking pool not set");

        // Check if user can claim reward
        require(verificationRegistry.canClaimReward(user), "Cannot claim reward");

        // Calculate reward
        uint256 reward = calculateReward(user);
        require(reward > 0, "No reward to distribute");

        // Mark reward as claimed
        verificationRegistry.markRewardClaimed(user);

        // Mint and distribute tokens
        token.mint(user, reward);

        emit RewardDistributed(user, reward);
        return reward;
    }

    /**
     * @notice Set daily APR
     * @param _dailyAPR New APR value (based on 10000)
     */
    function setDailyAPR(uint256 _dailyAPR) external onlyOwner {
        require(_dailyAPR <= 10_000, "APR too high");
        uint256 oldValue = dailyAPR;
        dailyAPR = _dailyAPR;
        emit DailyAPRSet(oldValue, _dailyAPR);
    }

    /**
     * @notice Set platform token contract address
     * @param _token Platform token contract address
     */
    function setToken(address _token) external onlyOwner {
        require(_token != address(0), "Invalid token address");
        token = IEcoCupToken(_token);
        emit TokenSet(_token);
    }

    /**
     * @notice Set verification registry contract address
     * @param _registry Verification registry contract address
     */
    function setVerificationRegistry(address _registry) external onlyOwner {
        require(_registry != address(0), "Invalid registry address");
        verificationRegistry = IVerificationRegistry(_registry);
        emit VerificationRegistrySet(_registry);
    }

    /**
     * @notice Set staking pool contract address
     * @param _stakingPool Staking pool contract address
     */
    function setStakingPool(address _stakingPool) external onlyOwner {
        require(_stakingPool != address(0), "Invalid staking pool address");
        stakingPool = IStakingPool(_stakingPool);
        emit StakingPoolSet(_stakingPool);
    }
}
