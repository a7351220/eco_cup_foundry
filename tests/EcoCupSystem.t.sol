// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import {Test, console} from "dependencies/forge-std/src/Test.sol";
import "../src/StakingPool.sol";
import "../src/EcoCupToken.sol";
import "../src/RewardController.sol";
import "../src/VerificationRegistry.sol";
import "../src/SelfVerification.sol";

contract EcoCupSystemTest is Test {

    StakingPool public stakingPool;
    EcoCupToken public ecoCupToken;
    RewardController public rewardController;
    VerificationRegistry public verificationRegistry;
    SelfVerification public selfVerification;

    address public deployer = address(1);
    address public user1 = address(2);
    address public user2 = address(3);

    uint256 public stakeAmount = 0.01 ether;
    address public mockVerificationHub = address(0x123);

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
        verificationRegistry.addVerifier(deployer);
        
        // 部署Self身份验证合约
        bool olderThanEnabled = true;
        uint256 olderThan = 18;
        bool forbiddenCountriesEnabled = false;
        uint256[4] memory forbiddenCountriesListPacked;
        bool[3] memory ofacEnabled = [false, false, false];
        
        selfVerification = new SelfVerification(
            mockVerificationHub,
            1001, // 应用ID
            1,    // 证件类型ID
            olderThanEnabled,
            olderThan,
            forbiddenCountriesEnabled,
            forbiddenCountriesListPacked,
            ofacEnabled
        );
        
        // 设置验证角色
        selfVerification.grantRole(selfVerification.VERIFIER_ROLE(), deployer);
        
        // 配置VerificationRegistry使用Self验证
        verificationRegistry.setSelfVerification(address(selfVerification));

        vm.stopPrank();
    }

    function testCompleteFlow() public {
        // 0. 先进行身份验证
        vm.prank(deployer);
        selfVerification.mockIdentityVerification(user1);
        
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
        // 0. 先进行身份验证
        vm.prank(deployer);
        selfVerification.mockIdentityVerification(user1);
        
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
        // 0. 为用户1和用户2进行身份验证
        vm.startPrank(deployer);
        selfVerification.mockIdentityVerification(user1);
        selfVerification.mockIdentityVerification(user2);
        vm.stopPrank();
        
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
    
    function testVerificationFailsWithoutIdentity() public {
        // 尝试在未进行身份验证的情况下进行验证
        vm.startPrank(deployer);
        
        // 应该失败
        vm.expectRevert("Identity verification required");
        verificationRegistry.recordVerification(user1);
        
        // 进行身份验证
        selfVerification.mockIdentityVerification(user1);
        
        // 现在应该成功
        verificationRegistry.recordVerification(user1);
        
        uint32 count = verificationRegistry.getVerificationCount(user1);
        assertEq(count, 1, "Verification count should be 1");
        
        vm.stopPrank();
    }
    
    function testDisablingIdentityVerification() public {
        // 测试禁用身份验证功能
        
        // 移除身份验证设置
        vm.prank(deployer);
        verificationRegistry.setSelfVerification(address(0));
        
        // 即使没有身份验证，也应该能进行验证
        vm.prank(deployer);
        verificationRegistry.recordVerification(user1);
        
        // 验证次数应该已记录
        uint32 count = verificationRegistry.getVerificationCount(user1);
        assertEq(count, 1, "Verification should be recorded without identity verification");
    }
}