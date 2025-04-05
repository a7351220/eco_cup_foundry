// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.28;

import "forge-std/Script.sol";
import "../src/EcoCupToken.sol";
import "../src/VerificationRegistry.sol";
import "../src/RewardController.sol";
import "../src/StakingPool.sol";
import "../src/SelfVerification.sol";

contract DeployEcoCup is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy EcoCupToken
        EcoCupToken token = new EcoCupToken("EcoCup Token", "ECT");
        
        // Deploy VerificationRegistry
        VerificationRegistry registry = new VerificationRegistry();
        
        // Deploy SelfVerification
        address mockVerificationHub = 0x77117D60eaB7C044e785D68edB6C7E0e134970Ea; // Self Verification Hub地址
        uint256 scope = 1001; // 应用ID
        uint256 attestationId = 1; // 证件类型ID (护照 = 1)
        bool olderThanEnabled = true;
        uint256 olderThan = 18; // 要求年满18岁
        bool forbiddenCountriesEnabled = false; // 不启用禁止国家列表
        uint256[4] memory forbiddenCountriesListPacked; // 空禁止国家列表
        bool[3] memory ofacEnabled = [false, false, false]; // 不启用OFAC检查
        
        SelfVerification selfVerification = new SelfVerification(
            mockVerificationHub,
            scope,
            attestationId,
            olderThanEnabled,
            olderThan,
            forbiddenCountriesEnabled,
            forbiddenCountriesListPacked,
            ofacEnabled
        );
        
        // 配置Self验证合约权限
        selfVerification.grantRole(selfVerification.VERIFIER_ROLE(), msg.sender);
        
        // 设置VerificationRegistry使用Self验证
        registry.setSelfVerification(address(selfVerification));
        
        // Deploy RewardController with token and registry addresses
        RewardController controller = new RewardController(address(token), address(registry));
        
        // Deploy StakingPool with token and controller addresses
        StakingPool pool = new StakingPool(address(token), address(controller));
        
        // Set up permissions and connections
        token.addMinter(address(controller));
        registry.addVerifier(address(controller));
        
        // Connect RewardController and StakingPool
        controller.setStakingPool(address(pool));
        pool.setRewardController(address(controller));
        
        vm.stopBroadcast();

        console.log("Deployed EcoCupToken at:", address(token));
        console.log("Deployed VerificationRegistry at:", address(registry));
        console.log("Deployed SelfVerification at:", address(selfVerification));
        console.log("Deployed RewardController at:", address(controller));
        console.log("Deployed StakingPool at:", address(pool));
    }
} 