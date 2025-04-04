# CupFi DeFi Verification System PRD

## 1. Product Overview
A Web3 application that combines staking mechanisms with eco-friendly behavior verification. Users stake ETH to gain verification eligibility and earn platform tokens by completing reusable cup verifications.

## 2. Core Features

### 2.1 Eco-friendly Behavior Verification
- Users upload photos of reusable cup usage
- AI automatic verification of compliance
- Timestamp and location verification
- 3 daily verifications required to unlock rewards

### 2.2 Staking Mechanism
- Minimum stake: 0.0001 ETH
- Stake enters official pool to gain verification eligibility
- Withdrawals available anytime
- Higher stake amounts earn higher reward multipliers

### 2.3 Official Reward Pool
- Officially maintained large staking pool
- Fixed APR platform token rewards
- Users automatically join official pool upon staking ETH
- Daily rewards unlocked after completing 3 cup verifications

### 2.4 Reward System
- Platform token rewards: Calculated based on staked amount and fixed APR
- Verification requirement: 3 daily verifications to unlock daily rewards

## 3. Innovation Highlights
- Integration of DeFi staking with eco-friendly behavior
- Staking mechanism ensures user behavior authenticity
- Direct link between daily eco-friendly actions and rewards
- Simple and effective incentive model

## 4. User Journey
1. User stakes ETH to enter official pool and gain verification eligibility
2. User takes photos during daily reusable cup usage (3 times required)
3. System automatically verifies photos and unlocks daily rewards
4. User can claim platform token rewards
5. User can choose to continue staking or withdraw ETH

## 5. Real User Flow Simulation

### 5.1 User Staking ETH
- User connects wallet to platform
- User stakes 0.01 ETH to StakingPool contract
- System records user's staked amount
- User's staking status activated, allowing participation in eco verifications

### 5.2 User Eco Verification
- User uses reusable cup and uploads photo to platform
- Platform verifiers (AI system + manual review) confirm photo validity
- Verifier calls VerificationRegistry contract to record verification
- User completes required 3 daily verifications (e.g., morning, noon, evening)

### 5.3 User Reward Eligibility
- System checks if user completed 3 verifications today
- System confirms user hasn't claimed today's rewards
- System confirms user's eligibility for rewards

### 5.4 System Reward Calculation
- Rewards calculated based on user's stake amount and daily APR (5%)
- Example: 0.01 ETH stake, 5% daily rate = 0.0005 ETH equivalent in tokens daily

### 5.5 User Reward Claim
- User clicks "Claim Reward" button
- RewardController contract calculates and distributes rewards
- System mints corresponding amount of EcoCupToken to user's wallet
- VerificationRegistry marks today's rewards as claimed to prevent double-claiming

### 5.6 User Reward View
- User can check accumulated EcoCupToken balance in wallet
- Tokens may have additional utilities like physical item redemption or ecosystem benefits

### 5.7 User Withdrawal (Optional)
- User can withdraw partial or full staked ETH if desired
- After withdrawal, user's reward potential decreases accordingly

### 5.8 Multi-user Scenarios
Different users staking different ETH amounts receive proportional rewards:
- User A stakes 0.01 ETH, earns ~0.0005 ETH equivalent in tokens daily after verification
- User B stakes 0.02 ETH, earns ~0.001 ETH equivalent in tokens daily after verification

## 6. MVP Scope

### Essential Features
- ETH staking and withdrawal
- Official reward pool mechanism
- Reusable cup photo verification (3 times daily)
- Platform token reward distribution
- Time verification

### Future Features (Version 2.0)
- Community-built staking pools
- Custom APR mechanism
- Advanced reward mechanisms
- Enhanced social sharing
- Achievement system
- Full-featured leaderboard

## 7. Technical Implementation Focus
- Smart Contracts: Staking and reward logic
- Platform Token Contract: ERC-20 token implementation
- AI Recognition: Reusable cup photo verification
- Frontend Interface: Clean and intuitive user experience
- Security Mechanism: Verification anti-cheat measures
- Scalability: Interface preparation for future community pool features

## 8. Success Metrics
- Daily active verification count
- Total ETH staked
- Platform token circulation
- User daily verification completion rate
- User retention rate
- Verification approval rate 