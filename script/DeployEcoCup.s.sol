// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.28;

import "forge-std-1.9.2/Script.sol";
import "../src/EcoCupToken.sol";
import "../src/VerificationRegistry.sol";
import "../src/RewardController.sol";
import "../src/StakingPool.sol";

contract DeployEcoCup is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Deploy EcoCupToken
        EcoCupToken token = new EcoCupToken("EcoCup Token", "ECT");
        
        // Deploy VerificationRegistry
        VerificationRegistry registry = new VerificationRegistry();
        
        // Deploy RewardController with token and registry addresses
        RewardController controller = new RewardController(address(token), address(registry));
        
        // Deploy StakingPool with token and controller addresses
        StakingPool pool = new StakingPool(address(token), address(controller));
        
        // Set up permissions
        token.addMinter(address(controller));
        
        vm.stopBroadcast();

        console.log("Deployed EcoCupToken at:", address(token));
        console.log("Deployed VerificationRegistry at:", address(registry));
        console.log("Deployed RewardController at:", address(controller));
        console.log("Deployed StakingPool at:", address(pool));
    }
} 