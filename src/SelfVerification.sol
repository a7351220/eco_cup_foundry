// SPDX-License-Identifier: MIT
pragma solidity >=0.8.28;

import "../node_modules/@selfxyz/contracts/contracts/abstract/SelfVerificationRoot.sol";
import "../node_modules/@selfxyz/contracts/contracts/interfaces/IVcAndDiscloseCircuitVerifier.sol";
import "../node_modules/@selfxyz/contracts/contracts/interfaces/IIdentityVerificationHubV1.sol";
import "../node_modules/@selfxyz/contracts/contracts/constants/CircuitConstants.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title SelfVerification
 * @notice implement Self identity verification system, integrate Self protocol identity verification functionality
 */
contract SelfVerification is SelfVerificationRoot, AccessControl {
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    
    // user identity verification status mapping
    mapping(address => bool) private _verifiedUsers;
    
    // used nullifier record (prevent replay)
    mapping(uint256 => bool) private _usedNullifiers;
    
    // event definition
    event IdentityVerified(address indexed user);
    
    /**
     * @notice constructor initializes Self verification system
     * @param _identityVerificationHub Self verification center address
     * @param _scope application identifier
     * @param _attestationId document type ID (1=passport)
     * @param _olderThanEnabled whether to enable age verification
     * @param _olderThan minimum age requirement
     * @param _forbiddenCountriesEnabled whether to enable forbidden countries list
     * @param _forbiddenCountriesListPacked packed forbidden countries list
     * @param _ofacEnabled OFAC check option
     */
    constructor(
        address _identityVerificationHub,
        uint256 _scope,
        uint256 _attestationId,
        bool _olderThanEnabled,
        uint256 _olderThan,
        bool _forbiddenCountriesEnabled,
        uint256[4] memory _forbiddenCountriesListPacked,
        bool[3] memory _ofacEnabled
    ) SelfVerificationRoot(
        _identityVerificationHub,
        _scope,
        _attestationId,
        _olderThanEnabled,
        _olderThan,
        _forbiddenCountriesEnabled,
        _forbiddenCountriesListPacked,
        _ofacEnabled
    ) {
        // set permissions
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(VERIFIER_ROLE, msg.sender);
    }
    
    /**
     * @notice override Self verification function, handle identity verification
     * @param proof identity verification proof
     */
    function verifySelfProof(
        IVcAndDiscloseCircuitVerifier.VcAndDiscloseProof memory proof
    ) public override {
        // 1. verify proof scope
        if (_scope != proof.pubSignals[CircuitConstants.VC_AND_DISCLOSE_SCOPE_INDEX]) {
            revert("Invalid scope");
        }
        
        // 2. verify proof attestation ID
        if (_attestationId != proof.pubSignals[CircuitConstants.VC_AND_DISCLOSE_ATTESTATION_ID_INDEX]) {
            revert("Invalid attestation ID");
        }
        
        // 3. verify nullifier is used (prevent replay)
        uint256 nullifier = proof.pubSignals[CircuitConstants.VC_AND_DISCLOSE_NULLIFIER_INDEX];
        if (_usedNullifiers[nullifier]) {
            revert("Nullifier already used");
        }
        
        // 4. call parent contract verification logic (verify proof and other verification conditions)
        super.verifySelfProof(proof);
        
        // 5. get user identifier and mark as verified
        address user = address(uint160(proof.pubSignals[CircuitConstants.VC_AND_DISCLOSE_USER_IDENTIFIER_INDEX]));
        _verifiedUsers[user] = true;
        _usedNullifiers[nullifier] = true;
        
        // 6. emit event
        emit IdentityVerified(user);
    }
    
    /**
     * @notice check if user is verified
     * @param user user address
     * @return if user is verified
     */
    function isIdentityVerified(address user) external view returns (bool) {
        return _verifiedUsers[user];
    }
    
    /**
     * @notice mock identity verification for testing purposes only
     * @param user user address
     * @dev this function can only be called by VERIFIER_ROLE, for testing purposes only
     */
    function mockIdentityVerification(address user) external onlyRole(VERIFIER_ROLE) {
        require(user != address(0), "Invalid user address");
        _verifiedUsers[user] = true;
        emit IdentityVerified(user);
    }
    
    /**
     * @dev inherit AccessControl permission check
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}