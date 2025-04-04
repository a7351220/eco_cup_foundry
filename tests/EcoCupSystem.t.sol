// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import {Test, console} from "dependencies/forge-std/src/Test.sol";
import "../src/StakingPool.sol";
import "../src/EcoCupToken.sol";
import "../src/RewardController.sol";
import "../src/VerificationRegistry.sol";

contract EcoCupSystemTest is Test {

    StakingPool public stakingPool;
    EcoCupToken public ecoCupToken;
    RewardController public rewardController;
    VerificationRegistry public verificationRegistry;

    address public deployer = address(1);
    address public user1 = address(2);
    address public user2 = address(3);

    uint256 public stakeAmount = 0.01 ether;

    function setUp() public {
        vm.startPrank(deployer);

        ecoCupToken = new EcoCupToken("EcoCup Token", "ECT");
        verificationRegistry = new VerificationRegistry();
        
        rewardController = new RewardController(address(ecoCupToken), address(verificationRegistry));
        stakingPool = new StakingPool(address(ecoCupToken), address(rewardController));
        
        stakingPool.setRewardController(address(rewardController));
        rewardController.setStakingPool(address(stakingPool));
        
        ecoCupToken.addMinter(address(rewardController));

        verificationRegistry.addVerifier(address(rewardController));

        vm.stopPrank();
    }

    function testCompleteFlow() public {
        // 1. User stakes ETH
        vm.deal(user1, 1 ether); // Give user1 some ETH
        vm.prank(user1);
        stakingPool.stake{value: stakeAmount}();

        // Verify staked amount
        assertEq(stakingPool.getStakedAmount(user1), stakeAmount, "Stakes not recorded correctly");

        // 2. Simulate verifier recording user1's verifications
        vm.startPrank(deployer);
        for (uint i = 0; i < 3; i++) {
            verificationRegistry.recordVerification(user1);
        }

        // 3. Verify if user can claim reward
        bool canClaim = verificationRegistry.canClaimReward(user1);
        assertTrue(canClaim, "User should be able to claim reward after 3 verifications");

        // 4. Calculate reward
        uint256 expectedReward = rewardController.calculateReward(user1);
        assertTrue(expectedReward > 0, "Reward should be greater than 0");

        // 5. Distribute reward
        uint256 distributedReward = rewardController.distributeReward(user1);
        assertEq(distributedReward, expectedReward, "Distributed reward should match calculated reward");

        // 6. Verify user token balance
        uint256 userBalance = ecoCupToken.balanceOf(user1);
        assertEq(userBalance, distributedReward, "User token balance should match distributed reward");

        // 7. Verify user cannot claim reward again
        bool canClaimAgain = verificationRegistry.canClaimReward(user1);
        assertFalse(canClaimAgain, "User should not be able to claim reward twice in the same day");
        
        vm.stopPrank();
    }

    function testWithdraw() public {
        // 1. User stakes ETH
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        stakingPool.stake{value: stakeAmount}();

        // Record initial balance
        uint256 initialBalance = user1.balance;

        // 2. User withdraws partial ETH
        vm.prank(user1);
        stakingPool.withdraw(stakeAmount / 2);

        // 3. Verify balance changes
        assertEq(stakingPool.getStakedAmount(user1), stakeAmount / 2, "Stake not reduced correctly");
        assertEq(user1.balance, initialBalance + (stakeAmount / 2), "ETH not returned correctly");
    }

    function testMultipleUsers() public {
        // Set up user funds
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
        
        // Users 1 and 2 stake different amounts
        vm.prank(user1);
        stakingPool.stake{value: stakeAmount}();
        
        vm.prank(user2);
        stakingPool.stake{value: stakeAmount * 2}();

        // Record verifications for both users
        vm.startPrank(deployer);
        for (uint i = 0; i < 3; i++) {
            verificationRegistry.recordVerification(user1);
            verificationRegistry.recordVerification(user2);
        }

        // Both users claim rewards
        uint256 reward1 = rewardController.distributeReward(user1);
        uint256 reward2 = rewardController.distributeReward(user2);

        // User2's reward should be double User1's (due to double stake amount)
        assertEq(reward2, reward1 * 2, "User2's reward should be double User1's reward");
        
        vm.stopPrank();
    }
} 