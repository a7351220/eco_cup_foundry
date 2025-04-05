// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import "../../node_modules/@selfxyz/contracts/contracts/interfaces/IVcAndDiscloseCircuitVerifier.sol";

/**
 * @title ISelfVerification
 * @notice Self身份验证系统接口
 */
interface ISelfVerification {
    /**
     * @notice 检查用户是否已通过身份验证
     * @param user 用户地址
     * @return 是否已验证
     */
    function isIdentityVerified(address user) external view returns (bool);
    
    /**
     * @notice 验证Self协议身份证明
     * @param proof 身份验证证明
     */
    function verifySelfProof(
        IVcAndDiscloseCircuitVerifier.VcAndDiscloseProof memory proof
    ) external;
    
    /**
     * @notice 仅用于测试的身份验证模拟函数
     * @param user 用户地址
     */
    function mockIdentityVerification(address user) external;
} 