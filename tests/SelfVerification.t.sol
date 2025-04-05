// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import {Test, console} from "dependencies/forge-std/src/Test.sol";
import "../src/StakingPool.sol";
import "../src/EcoCupToken.sol";
import "../src/RewardController.sol";
import "../src/VerificationRegistry.sol";
import "../src/SelfVerification.sol";

contract SelfVerificationTest is Test {
    // 系统合约
    StakingPool public stakingPool;
    EcoCupToken public ecoCupToken;
    RewardController public rewardController;
    VerificationRegistry public verificationRegistry;
    SelfVerification public selfVerification;

    // 测试账户
    address public deployer = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    address public verifier = address(4);

    // 测试参数
    uint256 public stakeAmount = 0.01 ether;
    address public mockVerificationHub = address(0x123); // 模拟Self验证中心
    uint256 public scope = 1001; // 应用标识符
    uint256 public attestationId = 1; // 证件类型ID (护照)

    function setUp() public {
        vm.startPrank(deployer);

        // 部署系统核心合约
        ecoCupToken = new EcoCupToken("EcoCup Token", "ECT");
        verificationRegistry = new VerificationRegistry();
        
        rewardController = new RewardController(address(ecoCupToken), address(verificationRegistry));
        stakingPool = new StakingPool(address(ecoCupToken), address(rewardController));
        
        // 配置合约依赖关系
        stakingPool.setRewardController(address(rewardController));
        rewardController.setStakingPool(address(stakingPool));
        ecoCupToken.addMinter(address(rewardController));
        verificationRegistry.addVerifier(address(rewardController));
        verificationRegistry.addVerifier(deployer);
        
        // 部署Self身份验证合约
        bool olderThanEnabled = true;
        uint256 olderThan = 18; // 要求年满18岁
        bool forbiddenCountriesEnabled = true;
        uint256[4] memory forbiddenCountriesListPacked; // 空禁止国家列表
        bool[3] memory ofacEnabled = [true, true, false]; // 启用部分OFAC检查
        
        selfVerification = new SelfVerification(
            mockVerificationHub,
            scope,
            attestationId,
            olderThanEnabled,
            olderThan,
            forbiddenCountriesEnabled,
            forbiddenCountriesListPacked,
            ofacEnabled
        );
        
        // 设置验证权限
        selfVerification.grantRole(selfVerification.VERIFIER_ROLE(), deployer);
        
        // 配置VerificationRegistry使用Self验证
        verificationRegistry.setSelfVerification(address(selfVerification));

        vm.stopPrank();
    }

    function testSelfVerificationBasic() public {
        // 测试基本Self验证功能
        vm.prank(deployer);
        selfVerification.mockIdentityVerification(user1);
        
        bool isVerified = selfVerification.isIdentityVerified(user1);
        assertTrue(isVerified, "User1 should be verified after mockIdentityVerification");
        
        bool user2Verified = selfVerification.isIdentityVerified(user2);
        assertFalse(user2Verified, "User2 should not be verified yet");
    }
    
    function testVerificationRequiresIdentity() public {
        // 用户尝试在未验证身份的情况下进行验证
        vm.startPrank(deployer);
        
        // 用户1未验证身份，应该无法完成验证
        vm.expectRevert("Identity verification required");
        verificationRegistry.recordVerification(user1);
        
        // 为用户1完成身份验证
        selfVerification.mockIdentityVerification(user1);
        
        // 现在应该可以完成验证
        verificationRegistry.recordVerification(user1);
        
        uint32 verificationCount = verificationRegistry.getVerificationCount(user1);
        assertEq(verificationCount, 1, "Verification count should be 1 after recordVerification");
        
        vm.stopPrank();
    }
    
    function testCompleteFlowWithIdentity() public {
        // 测试包含身份验证的完整流程
        
        // 1. 用户进行身份验证
        vm.prank(deployer);
        selfVerification.mockIdentityVerification(user1);
        
        // 2. 用户质押ETH
        vm.deal(user1, 1 ether);
        vm.prank(user1);
        stakingPool.stake{value: stakeAmount}();
        
        // 验证质押金额
        assertEq(stakingPool.getStakedAmount(user1), stakeAmount, "Stake amount incorrect");
        
        // 3. 模拟记录验证
        vm.startPrank(deployer);
        for (uint i = 0; i < 3; i++) {
            verificationRegistry.recordVerification(user1);
        }
        
        // 4. 验证用户是否可以领取奖励
        bool canClaim = verificationRegistry.canClaimReward(user1);
        assertTrue(canClaim, "User should be able to claim reward after 3 verifications");
        
        // 5. 计算并发放奖励
        uint256 expectedReward = rewardController.calculateReward(user1);
        assertTrue(expectedReward > 0, "Reward should be positive");
        
        uint256 distributedReward = rewardController.distributeReward(user1);
        assertEq(distributedReward, expectedReward, "Distributed reward should match expected");
        
        // 6. 验证代币余额
        uint256 tokenBalance = ecoCupToken.balanceOf(user1);
        assertEq(tokenBalance, distributedReward, "Token balance should match distributed reward");
        
        vm.stopPrank();
    }
    
    function testMultipleUsersWithIdentity() public {
        // 测试多用户场景
        
        // 为用户1和用户2完成身份验证
        vm.startPrank(deployer);
        selfVerification.mockIdentityVerification(user1);
        selfVerification.mockIdentityVerification(user2);
        vm.stopPrank();
        
        // 用户质押不同金额的ETH
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
        
        vm.prank(user1);
        stakingPool.stake{value: stakeAmount}();
        
        vm.prank(user2);
        stakingPool.stake{value: stakeAmount * 2}();
        
        // 记录验证
        vm.startPrank(deployer);
        for (uint i = 0; i < 3; i++) {
            verificationRegistry.recordVerification(user1);
            verificationRegistry.recordVerification(user2);
        }
        
        // 发放奖励
        uint256 reward1 = rewardController.distributeReward(user1);
        uint256 reward2 = rewardController.distributeReward(user2);
        
        // 验证奖励比例
        assertEq(reward2, reward1 * 2, "User2's reward should be double User1's reward");
        
        vm.stopPrank();
    }
    
    function testIdentityVerificationRequired() public {
        // 测试未设置Self验证时的行为
        
        // 先解除Self验证设置
        vm.prank(deployer);
        verificationRegistry.setSelfVerification(address(0));
        
        // 在未设置Self验证的情况下，所有用户应该被视为已验证
        bool verified = verificationRegistry.isIdentityVerified(user1);
        assertTrue(verified, "User should be considered verified when Self verification is not set");
        
        // 应该能够正常记录验证
        vm.prank(deployer);
        verificationRegistry.recordVerification(user1);
        
        uint32 count = verificationRegistry.getVerificationCount(user1);
        assertEq(count, 1, "Verification should be recorded when Self verification is not set");
    }
}