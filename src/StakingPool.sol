// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/IRewardController.sol";

/**
 * @title StakingPool
 * @notice Manages user ETH staking and provides verification eligibility
 */
contract StakingPool is Ownable, ReentrancyGuard {
    uint256 public constant MIN_STAKE_AMOUNT = 0.0001 ether;

    mapping(address => uint256) public stakedAmount;
    IRewardController public rewardController;

    // Event definitions
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardControllerSet(address indexed controller);

    /**
     * @notice Constructor sets contract deployer as initial owner
     */
    constructor(address /* _token */, address _controller) Ownable(msg.sender) { 
        require(_controller != address(0), "Invalid controller address");
        rewardController = IRewardController(_controller);
    }

    /**
     * @notice Stake ETH into the pool
     * @dev User must stake at least MIN_STAKE_AMOUNT of ETH
     */
    function stake() external payable {
        require(msg.value >= MIN_STAKE_AMOUNT, "Stake below minimum");

        stakedAmount[msg.sender] += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw staked ETH
     * @param amount Amount of ETH to withdraw
     */
    function withdraw(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be positive");
        require(stakedAmount[msg.sender] >= amount, "Insufficient staked amount");

        stakedAmount[msg.sender] -= amount;
        (bool success,) = msg.sender.call{ value: amount }("");
        require(success, "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @notice Get user's staked ETH amount
     * @param user User address
     * @return Amount of staked ETH
     */
    function getStakedAmount(address user) external view returns (uint256) {
        return stakedAmount[user];
    }

    /**
     * @notice Set reward controller address
     * @param _rewardController Reward controller contract address
     */
    function setRewardController(address _rewardController) external onlyOwner {
        require(_rewardController != address(0), "Invalid controller address");
        rewardController = IRewardController(_rewardController);
        emit RewardControllerSet(_rewardController);
    }
}
