# Eco-Friendly Cup DeFi Verification System Technical Specification

## Version Information
- **Solidity**: v0.8.28 (specified in foundry.toml)
- **Foundry**: v1.9.2 (referenced in dependencies)
- **OpenZeppelin**: v5.0.1 (referenced in package.json)

## 1. Technical Architecture Overview

### 1.1 Smart Contract Architecture
This project implements the following smart contracts:

1. **StakingPool.sol** - Manages ETH staking and withdrawal functionality
2. **EcoCupToken.sol** - Implements ERC-20 standard platform token
3. **RewardController.sol** - Manages reward calculation and distribution
4. **VerificationRegistry.sol** - Records user verification status and history

![Contract Architecture Diagram]
```
StakingPool <-----> RewardController <-----> EcoCupToken
     ^                     ^                       ^
     |                     |                       |
     v                     v                       v
       VerificationRegistry <-----> Frontend Application
```

### 1.2 Technical Dependencies
- Uses OpenZeppelin's ERC-20 implementation
- Uses Foundry for development, testing, and deployment
- Uses Solidity v0.8.28 as the smart contract language

## 2. Implemented Smart Contracts

### 2.1 StakingPool.sol
Staking pool contract allows users to stake ETH and supports withdrawals. Key features:
- Minimum stake amount is 0.0001 ETH
- Users can withdraw staked ETH at any time
- Tracks each user's staked amount
- Interfaces with the reward controller

### 2.2 EcoCupToken.sol
ERC-20 token contract for user rewards. Key features:
- Based on OpenZeppelin's ERC-20 implementation
- Uses AccessControl for permission management
- Defines MINTER_ROLE to control token minting permissions

### 2.3 RewardController.sol
Reward controller contract manages reward calculations and distribution. Key features:
- Calculates rewards based on user stake amount and APR
- Interacts with staking pool and verification registry
- Supports configurable APR
- Mints tokens as rewards

### 2.4 VerificationRegistry.sol
Verification registry contract records user verification status. Key features:
- Requires 3 verifications per day to claim rewards
- Uses AccessControl to define verifier roles
- Tracks user daily verification count and reward claim status

## 3. Implementation Details

### 3.1 Staking Functionality
- Users must stake at least 0.0001 ETH to be eligible for verification
- Users can withdraw staked ETH at any time
- Higher stake amounts result in higher rewards

### 3.2 Verification Mechanism
- 3 verifications per day required to unlock rewards
- Verification status stored on-chain
- Verifications confirmed by authorized verifier accounts
- Daily verification count resets each new day

### 3.3 Reward Calculation
- Rewards based on user's staked ETH amount and fixed APR
- Default APR is 5% (represented as 500 with base 10000)
- Rewards can only be claimed after completing 3 daily verifications

## 4. Simplified Testing Strategy

### 4.1 Basic Functionality Tests
- Test staking and withdrawal functionality
- Test verification recording functionality
- Test reward calculation and distribution functionality

### 4.2 Integration Tests
- Test basic contract interactions
- Test simple user flow: stake, verify, claim rewards

## 5. Deployment Plan

### 5.1 Contract Deployment
- Deploy contracts in the following order:
  1. EcoCupToken
  2. VerificationRegistry
  3. StakingPool
  4. RewardController
- Configure contract relationships
- Set initial parameters and permissions

## 6. Frontend Integration Points

### 6.1 Contract Interaction
- Use ethers.js or web3.js for contract interaction
- Implement wallet connection
- Handle transaction states

### 6.2 Verification Flow
- Frontend captures eco-friendly cup photos
- Verification results submitted on-chain through verifier
- Display user verification status and progress

### 6.3 User Interface
- Display user stake amount
- Show daily verification completion status
- Display claimable rewards
- Provide staking and withdrawal functionality

## 7. Future Extension Interfaces

### 7.1 Community Staking Pools
Reserved interfaces:
```solidity
interface ICommunityPool {
    function createPool(uint256 apr, uint256 minStake) external;
    function joinPool(uint256 poolId) external payable;
    function leavePool(uint256 poolId, uint256 amount) external;
}
```

### 7.2 Advanced Reward Mechanisms
Reserved interfaces:
```solidity
interface IAdvancedRewards {
    function setCustomRewardStrategy(address strategy) external;
    function addBonusMultiplier(uint256 multiplier, uint256 threshold) external;
}
```

## 8. Monitoring and Maintenance

### 8.1 On-chain Monitoring
- Monitor total staked amount
- Monitor reward distribution
- Monitor user verification activity

### 8.2 Upgrade Path
- Reserve contract upgrade path
- Critical parameters adjustable by admin
- Reserve interfaces for feature expansion 