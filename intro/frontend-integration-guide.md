# Eco-Friendly Cup DeFi Verification System - Contract Functions and Events Reference

This document provides a reference for smart contract functions and events in the Eco-Friendly Cup DeFi Verification System, for frontend developers using the Wagmi library for integration.

## Table of Contents
1. [Smart Contract Addresses](#smart-contract-addresses)
2. [StakingPool Contract](#stakingpool-contract)
3. [VerificationRegistry Contract](#verificationregistry-contract)
4. [RewardController Contract](#rewardcontroller-contract)
5. [EcoCupToken Contract](#ecocuptoken-contract)
6. [Self Identity Verification Integration](#self-identity-verification-integration)
7. [Common Use Cases](#common-use-cases)

## Smart Contract Addresses

Below are the deployed smart contract addresses (Celo Alfajores Testnet):

- EcoCupToken: `0x098C568b8EFd867E089D130504d6CE9218519Dc2`
- VerificationRegistry: `0xF7C7a89e994a96C227E5911326aCdd5324261Fa3`
- SelfVerification: `0x73a166998f24878c7d1Dd55230A9281AAfEb43C8`
- RewardController: `0x3eA8E0860008fE95E22F2fb68728f40918Eed89E`
- StakingPool: `0x6075431B8eB46fc86c100b44eD669766363e76E6`

## StakingPool Contract

### Callable Functions

#### stake
- **Description**: Users stake ETH in the pool to gain verification eligibility
- **Parameters**: None (but requires sending ETH)
- **Returns**: None
- **Notes**:
  - Sent ETH must be >= 0.0001 ETH (MIN_STAKE_AMOUNT)
  - Write operation, requires signature

#### withdraw
- **Description**: Withdraw previously staked ETH
- **Parameters**:
  - `amount` (uint256) - Amount of ETH to withdraw (in Wei)
- **Returns**: None
- **Notes**:
  - User cannot withdraw more than their staked amount
  - Write operation, requires signature

#### getStakedAmount
- **Description**: Get the staked amount for a specified user
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - `uint256` - Amount of ETH staked by user (in Wei)
- **Notes**:
  - Read-only operation, no signature required

### Events

#### Staked
- **Description**: Triggered when a user successfully stakes ETH
- **Parameters**:
  - `user` (address indexed) - Address of the staking user
  - `amount` (uint256) - Amount of ETH staked

#### Withdrawn
- **Description**: Triggered when a user successfully withdraws ETH
- **Parameters**:
  - `user` (address indexed) - Address of the withdrawing user
  - `amount` (uint256) - Amount of ETH withdrawn

## VerificationRegistry Contract

### Callable Functions

#### recordVerification
- **Description**: Record a user's completion of an eco-friendly cup usage verification
- **Parameters**:
  - `user` (address) - Address of the user completing verification
- **Returns**: None
- **Notes**:
  - Only addresses with VERIFIER_ROLE can call this
  - User must have completed Self identity verification
  - Write operation, requires signature

#### canClaimReward
- **Description**: Check if a user can claim today's reward
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - `bool` - Whether reward can be claimed
- **Notes**:
  - User must complete 3 verifications today and not yet claimed today's reward
  - Read-only operation, no signature required

#### getVerificationCount
- **Description**: Get user's verification count for today
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - `uint32` - Number of verifications completed today
- **Notes**:
  - Read-only operation, no signature required

#### userVerifications
- **Description**: Get detailed verification status for a user
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - Struct (uint256 date, uint32 count, bool rewardClaimed)
    - `date` - Date of most recent verification (in days)
    - `count` - Verification count for the day
    - `rewardClaimed` - Whether reward has been claimed
- **Notes**:
  - Read-only operation, no signature required

#### isIdentityVerified
- **Description**: Check if a user has completed Self identity verification
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - `bool` - Whether the user has completed identity verification
- **Notes**:
  - Read-only operation, no signature required
  - Returns true for all users if Self verification is disabled

### Events

#### VerificationRecorded
- **Description**: Triggered when a user's verification is successfully recorded
- **Parameters**:
  - `user` (address indexed) - User address
  - `date` (uint256) - Verification date (in days)
  - `count` (uint32) - Cumulative verification count for the day

#### RewardClaimed
- **Description**: Triggered when a user successfully claims a reward
- **Parameters**:
  - `user` (address indexed) - User address
  - `date` (uint256) - Date of reward claim (in days)

## RewardController Contract

### Callable Functions

#### calculateReward
- **Description**: Calculate the reward amount a user can receive
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - `uint256` - Amount of reward tokens that can be received
- **Notes**:
  - Reward based on user's staked ETH amount and current APR
  - Read-only operation, no signature required

#### distributeReward
- **Description**: Distribute reward tokens to a user
- **Parameters**:
  - `user` (address) - Address of the reward recipient
- **Returns**:
  - `uint256` - Amount of reward tokens distributed
- **Notes**:
  - User must complete 3 verifications today and not yet claimed today's reward
  - Write operation, requires signature

#### dailyAPR
- **Description**: Get the current daily APR value
- **Parameters**: None
- **Returns**:
  - `uint256` - Daily APR value (base 10000)
- **Notes**:
  - For example, return value 500 means 5.00%
  - Read-only operation, no signature required

### Events

#### RewardDistributed
- **Description**: Triggered when a user successfully claims rewards
- **Parameters**:
  - `user` (address indexed) - User address
  - `amount` (uint256) - Amount of reward tokens

## EcoCupToken Contract

### Callable Functions

#### balanceOf (ERC-20 Standard Function)
- **Description**: Get token balance for specified address
- **Parameters**:
  - `account` (address) - Address to query balance for
- **Returns**:
  - `uint256` - Token balance
- **Notes**:
  - Read-only operation, no signature required

#### transfer (ERC-20 Standard Function)
- **Description**: Transfer tokens to specified address
- **Parameters**:
  - `to` (address) - Recipient address
  - `amount` (uint256) - Amount of tokens to transfer
- **Returns**:
  - `bool` - Success status
- **Notes**:
  - Write operation, requires signature

#### mint
- **Description**: Mint tokens to specified address
- **Parameters**:
  - `to` (address) - Address to receive tokens
  - `amount` (uint256) - Amount of tokens to mint
- **Returns**: None
- **Notes**:
  - Only addresses with MINTER_ROLE can call this
  - Write operation, requires signature

### Events

#### Transfer (ERC-20 Standard Event)
- **Description**: Triggered when tokens are transferred
- **Parameters**:
  - `from` (address indexed) - Address of the sender
  - `to` (address indexed) - Address of the recipient
  - `value` (uint256) - Amount of tokens transferred

## Self Identity Verification Integration

The EcoCup system uses Self protocol for identity verification. Users must complete identity verification before they can participate in the cup usage verification process. This section provides detailed implementation guidance for integrating Self identity verification into your frontend application.

### Required Packages

Install the necessary Self SDK packages:

```bash
npm install @selfxyz/qrcode @selfxyz/core
# OR
yarn add @selfxyz/qrcode @selfxyz/core
```

### 1. SelfVerification Contract Interface

#### verifySelfProof
- **Description**: Verifies a Self identity proof
- **Parameters**:
  - `proof` (VcAndDiscloseProof) - Zero-knowledge proof of user's identity
- **Returns**: None
- **Notes**:
  - This function is called by the backend after receiving proof from Self
  - The function checks that the proof is valid and marks the user as verified
  - Write operation

#### isIdentityVerified
- **Description**: Check if a user has completed identity verification
- **Parameters**:
  - `user` (address) - User address
- **Returns**:
  - `bool` - Whether user is verified
- **Notes**:
  - Read-only operation, no signature required

#### mockIdentityVerification (Testing Only)
- **Description**: Mock function for testing identity verification
- **Parameters**:
  - `user` (address) - User address to mark as verified
- **Returns**: None
- **Notes**:
  - Only callable by addresses with VERIFIER_ROLE
  - Only for testing environments
  - Write operation, requires signature

### 2. Frontend Implementation

#### Identity Verification Component

Create a component that displays the Self QR code for users to scan:

```tsx
// components/SelfVerification.tsx
'use client';

import React, { useEffect } from 'react';
import { useAccount, useContractRead } from 'wagmi';
import SelfQRcodeWrapper, { SelfApp, SelfAppBuilder } from '@selfxyz/qrcode';
import { verificationRegistryAddress, verificationRegistryABI } from '../constants/contracts';

// Optional: Your application logo in Base64 format
import { appLogo } from '../assets/appLogo';

interface SelfVerificationProps {
  onVerificationSuccess?: () => void;
}

const SelfVerification: React.FC<SelfVerificationProps> = ({ onVerificationSuccess }) => {
  const { address, isConnected } = useAccount();

  // Check if user is already verified
  const { data: isVerified, isLoading, refetch } = useContractRead({
    address: verificationRegistryAddress,
    abi: verificationRegistryABI,
    functionName: 'isIdentityVerified',
    args: [address],
    enabled: !!address,
  });

  // Create Self app instance
  const selfApp = address ? new SelfAppBuilder({
    appName: "EcoCup Verification",
    scope: "1001", // Must match the scope set in your SelfVerification contract
    endpoint: "/api/verify", // Your backend API endpoint
    logoBase64: appLogo, // Your app logo
    userId: address,
    userIdType: "hex",
    disclosures: { 
      date_of_birth: true, // Request user's date of birth
      // Uncomment if you need country information:
      // country: true, 
    },
    devMode: process.env.NODE_ENV !== 'production',
  }).build() : null;

  // Handle successful verification
  const handleSuccess = async () => {
    console.log('Identity verification initiated successfully');
    
    // Refetch verification status after a delay to allow for transaction processing
    setTimeout(() => {
      refetch();
      if (onVerificationSuccess) {
        onVerificationSuccess();
      }
    }, 5000);
  };

  if (isLoading) return <div className="text-center">Checking verification status...</div>;
  
  if (isVerified) return (
    <div className="p-4 bg-green-100 text-green-800 rounded-md">
      ✓ Your identity has been verified
    </div>
  );

  return (
    <div className="flex flex-col items-center p-4 border rounded-lg">
      <h2 className="text-xl font-semibold mb-4">Identity Verification Required</h2>
      <p className="mb-4 text-center">
        Please scan this QR code with the Self app to verify your identity.
        This is required before you can participate in the EcoCup verification process.
      </p>
      
      {!isConnected ? (
        <div className="text-red-600">Please connect your wallet first</div>
      ) : !address ? (
        <div className="text-yellow-600">Wallet address not available</div>
      ) : !selfApp ? (
        <div className="text-yellow-600">Loading verification QR code...</div>
      ) : (
        <div className="flex justify-center p-2 bg-white rounded-md shadow-md">
          <SelfQRcodeWrapper
            selfApp={selfApp}
            type='websocket'
            onSuccess={handleSuccess}
          />
        </div>
      )}
      
      <div className="mt-4 text-sm text-gray-600">
        Don't have the Self app? 
        <a 
          href="https://self.xyz/download" 
          target="_blank" 
          rel="noopener noreferrer"
          className="ml-1 text-blue-600 hover:underline"
        >
          Download here
        </a>
      </div>
    </div>
  );
};

export default SelfVerification;
```

#### Integration in Main Verification Flow

In your main application flow, check for identity verification before allowing cup verification:

```tsx
// pages/verification.tsx
'use client';

import React, { useState } from 'react';
import { useAccount, useContractRead } from 'wagmi';
import SelfVerification from '../components/SelfVerification';
import CupVerificationUpload from '../components/CupVerificationUpload';
import { verificationRegistryAddress, verificationRegistryABI } from '../constants/contracts';

const VerificationPage: React.FC = () => {
  const { address } = useAccount();
  const [verificationCompleted, setVerificationCompleted] = useState(false);

  // Check if user is identity verified
  const { data: isIdentityVerified, isLoading: isCheckingIdentity } = useContractRead({
    address: verificationRegistryAddress,
    abi: verificationRegistryABI,
    functionName: 'isIdentityVerified',
    args: [address],
    enabled: !!address,
  });

  // Get today's verification count
  const { data: verificationCount, isLoading: isCheckingCount, refetch: refetchCount } = useContractRead({
    address: verificationRegistryAddress,
    abi: verificationRegistryABI,
    functionName: 'getVerificationCount',
    args: [address],
    enabled: !!address && !!isIdentityVerified,
  });

  const handleVerificationSuccess = () => {
    setVerificationCompleted(true);
    refetchCount();
  };

  if (!address) {
    return <div className="p-4">Please connect your wallet to continue</div>;
  }

  if (isCheckingIdentity) {
    return <div className="p-4">Checking identity verification status...</div>;
  }

  return (
    <div className="container mx-auto max-w-2xl px-4 py-8">
      <h1 className="text-2xl font-bold mb-6">EcoCup Verification</h1>
      
      {/* Step 1: Identity Verification */}
      {!isIdentityVerified && (
        <div className="mb-8">
          <h2 className="text-xl font-semibold mb-4">Step 1: Identity Verification</h2>
          <SelfVerification onVerificationSuccess={handleVerificationSuccess} />
        </div>
      )}
      
      {/* Step 2: Cup Verification */}
      {isIdentityVerified && (
        <div>
          <h2 className="text-xl font-semibold mb-4">Step 2: Cup Usage Verification</h2>
          
          {!isCheckingCount && (
            <div className="mb-4">
              <p>Today's verifications: <strong>{Number(verificationCount || 0)}/3</strong></p>
            </div>
          )}
          
          <CupVerificationUpload 
            onVerificationSuccess={handleVerificationSuccess}
            disabledMessage={Number(verificationCount || 0) >= 3 ? "You've reached the daily verification limit" : ""}
          />
        </div>
      )}
    </div>
  );
};

export default VerificationPage;
```

### 3. Backend Implementation

Create an API endpoint to handle the verification from Self:

```typescript
// pages/api/verify.ts
import { NextApiRequest, NextApiResponse } from 'next';
import { getUserIdentifier } from '@selfxyz/core';
import { ethers } from 'ethers';
import { selfVerificationABI } from '../../constants/contracts';

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== 'POST') {
    return res.status(405).json({ message: 'Method not allowed' });
  }

  try {
    const { proof, publicSignals } = req.body;

    if (!proof || !publicSignals) {
      return res.status(400).json({ 
        message: 'Proof and publicSignals are required' 
      });
    }

    console.log("Received proof:", proof);
    console.log("Received public signals:", publicSignals);

    // Extract user address from verification result
    const userAddress = await getUserIdentifier(publicSignals, "hex");
    console.log("User address from verification:", userAddress);

    // Connect to Base Sepolia network
    const provider = new ethers.JsonRpcProvider(process.env.RPC_URL || "https://sepolia.base.org");
    const signer = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
    
    const selfVerificationAddress = process.env.SELF_VERIFICATION_ADDRESS;
    
    if (!selfVerificationAddress) {
      return res.status(500).json({ 
        message: 'Self verification contract address not configured' 
      });
    }

    const contract = new ethers.Contract(
      selfVerificationAddress,
      selfVerificationABI,
      signer
    );

    try {
      // Call the contract to verify the proof
      // Note: The proof format must be transformed for the contract
      const tx = await contract.verifySelfProof({
        a: proof.a,
        b: [
          [proof.b[0][1], proof.b[0][0]],  // Note: b array indices are swapped
          [proof.b[1][1], proof.b[1][0]],
        ],
        c: proof.c,
        pubSignals: publicSignals,
      });

      // Wait for transaction confirmation
      const receipt = await tx.wait();
      console.log("Transaction confirmed:", receipt.hash);

      return res.status(200).json({
        status: 'success',
        result: true,
        message: 'Identity verification successful',
        txHash: receipt.hash
      });
    } catch (contractError) {
      console.error("Contract call failed:", contractError);
      return res.status(400).json({
        status: 'error',
        result: false,
        message: 'Verification failed on the blockchain',
        error: contractError instanceof Error ? contractError.message : 'Unknown contract error'
      });
    }
  } catch (error) {
    console.error('Server error:', error);
    return res.status(500).json({
      status: 'error',
      message: 'Server error processing verification',
      result: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
}
```

### 4. Environment Configuration

Create a `.env.local` file with the required configuration:

```
# RPC URL for Celo Alfajores
RPC_URL=https://alfajores-forno.celo-testnet.org

# Backend private key (for signing transactions to the blockchain)
PRIVATE_KEY=your_private_key_here

# Contract addresses
SELF_VERIFICATION_ADDRESS=0x73a166998f24878c7d1Dd55230A9281AAfEb43C8
VERIFICATION_REGISTRY_ADDRESS=0xF7C7a89e994a96C227E5911326aCdd5324261Fa3
REWARD_CONTROLLER_ADDRESS=0x3eA8E0860008fE95E22F2fb68728f40918Eed89E
STAKING_POOL_ADDRESS=0x6075431B8eB46fc86c100b44eD669766363e76E6
ECO_CUP_TOKEN_ADDRESS=0x098C568b8EFd867E089D130504d6CE9218519Dc2
```

Make sure to never commit your private key to version control!

### 5. Contract ABIs

Create ABI files for your contracts:

```typescript
// constants/contracts.ts
export const verificationRegistryAddress = process.env.NEXT_PUBLIC_VERIFICATION_REGISTRY_ADDRESS || '0xF7C7a89e994a96C227E5911326aCdd5324261Fa3';
export const selfVerificationAddress = process.env.NEXT_PUBLIC_SELF_VERIFICATION_ADDRESS || '0x73a166998f24878c7d1Dd55230A9281AAfEb43C8';

export const selfVerificationABI = [
  {
    "inputs": [
      {
        "components": [
          { "internalType": "uint256[2]", "name": "a", "type": "uint256[2]" },
          { "internalType": "uint256[2][2]", "name": "b", "type": "uint256[2][2]" },
          { "internalType": "uint256[2]", "name": "c", "type": "uint256[2]" },
          { "internalType": "uint256[]", "name": "pubSignals", "type": "uint256[]" }
        ],
        "internalType": "struct IVcAndDiscloseCircuitVerifier.VcAndDiscloseProof",
        "name": "proof",
        "type": "tuple"
      }
    ],
    "name": "verifySelfProof",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "user", "type": "address" }
    ],
    "name": "isIdentityVerified",
    "outputs": [
      { "internalType": "bool", "name": "", "type": "bool" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "user", "type": "address" }
    ],
    "name": "mockIdentityVerification",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
];

export const verificationRegistryABI = [
  {
    "inputs": [
      { "internalType": "address", "name": "user", "type": "address" }
    ],
    "name": "isIdentityVerified",
    "outputs": [
      { "internalType": "bool", "name": "", "type": "bool" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "user", "type": "address" }
    ],
    "name": "recordVerification",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "user", "type": "address" }
    ],
    "name": "getVerificationCount",
    "outputs": [
      { "internalType": "uint32", "name": "", "type": "uint32" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      { "internalType": "address", "name": "user", "type": "address" }
    ],
    "name": "canClaimReward",
    "outputs": [
      { "internalType": "bool", "name": "", "type": "bool" }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  // Add other necessary functions...
];

// Add other contract ABIs as needed
```

### 6. Implementation Notes

1. **Self App on Mobile Device**: Users need to have the Self app installed on their mobile device to scan the QR code. Provide a download link for users who don't have the app.

2. **Websocket Communication**: The example uses websocket communication (`type='websocket'`) which allows for real-time updates between the Self app and your website.

3. **Special Proof Format**: Note the special format for the proof's `b` parameter when calling the verifySelfProof function:
   ```typescript
   b: [
     [proof.b[0][1], proof.b[0][0]],  // Indices are swapped!
     [proof.b[1][1], proof.b[1][0]],
   ]
   ```
   This format is required by the Solidity contract.

4. **Server-Side API Key**: In production, you should secure your API with appropriate authentication and rate limiting.

5. **Error Handling**: Implement comprehensive error handling in both frontend and backend to provide a good user experience.

6. **Testing Mode**: For testing, you can use the `mockIdentityVerification` function, but remember this requires the caller to have the `VERIFIER_ROLE`.

### 7. Admin Verification Path

For admin users with `VERIFIER_ROLE`, you can implement a direct verification path that bypasses the QR code scanning process. This is useful for testing and administrative purposes.

#### Implementing Dual Verification Paths

Create a component that shows both verification options based on user permissions:

```tsx
// components/IdentityVerification.tsx
'use client';

import React, { useState } from 'react';
import { useAccount, useContractRead, useContractWrite } from 'wagmi';
import SelfQRcodeWrapper, { SelfAppBuilder } from '@selfxyz/qrcode';
import { 
  selfVerificationAddress, 
  selfVerificationABI, 
  verificationRegistryAddress, 
  verificationRegistryABI 
} from '../constants/contracts';
import { appLogo } from '../assets/appLogo';

// The keccak256 hash of "VERIFIER_ROLE"
const VERIFIER_ROLE = "0x3a9a1512256ee5e7f6e09557a22aaf332f9a6bd11da45478ec08c5418f96a1b4";

const IdentityVerification: React.FC = () => {
  const { address } = useAccount();
  const [targetAddress, setTargetAddress] = useState("");
  
  // Check if user has VERIFIER_ROLE
  const { data: hasVerifierRole } = useContractRead({
    address: selfVerificationAddress,
    abi: selfVerificationABI,
    functionName: 'hasRole',
    args: [VERIFIER_ROLE, address],
    enabled: !!address,
  });
  
  // Check if user is already verified
  const { data: isVerified, isLoading, refetch: refetchVerification } = useContractRead({
    address: verificationRegistryAddress,
    abi: verificationRegistryABI,
    functionName: 'isIdentityVerified',
    args: [address],
    enabled: !!address,
  });
  
  // Setup mock verification function call
  const { write: mockVerify, isLoading: isMockVerifying } = useContractWrite({
    address: selfVerificationAddress,
    abi: selfVerificationABI,
    functionName: 'mockIdentityVerification',
  });
  
  // Create Self app instance for QR code
  const selfApp = address ? new SelfAppBuilder({
    appName: "EcoCup Verification",
    scope: "1001",
    endpoint: "/api/verify",
    logoBase64: appLogo,
    userId: address,
    userIdType: "hex",
    disclosures: { date_of_birth: true },
    devMode: process.env.NODE_ENV !== 'production',
  }).build() : null;
  
  // Handle successful QR verification
  const handleSuccess = async () => {
    console.log('Identity verification initiated successfully');
    setTimeout(() => refetchVerification(), 5000);
  };
  
  // Handle admin direct verification
  const handleAdminVerify = () => {
    if (!targetAddress) {
      alert("Please enter a wallet address to verify");
      return;
    }
    mockVerify({ args: [targetAddress] });
    setTimeout(() => {
      if (targetAddress.toLowerCase() === address?.toLowerCase()) {
        refetchVerification();
      }
    }, 3000);
  };
  
  if (isLoading) return <div className="text-center">Checking verification status...</div>;
  
  if (isVerified) return (
    <div className="p-4 bg-green-100 text-green-800 rounded-md">
      ✓ Your identity has been verified
    </div>
  );
  
  return (
    <div className="space-y-8">
      {/* Standard User Verification Path */}
      <div className="flex flex-col items-center p-4 border rounded-lg">
        <h2 className="text-xl font-semibold mb-4">Identity Verification</h2>
        <p className="mb-4 text-center">
          Please scan this QR code with the Self app to verify your identity.
        </p>
        
        <div className="flex justify-center p-2 bg-white rounded-md shadow-md">
          <SelfQRcodeWrapper
            selfApp={selfApp}
            type='websocket'
            onSuccess={handleSuccess}
          />
        </div>
        
        <div className="mt-4 text-sm text-gray-600">
          Don't have the Self app? 
          <a 
            href="https://self.xyz/download" 
            target="_blank" 
            rel="noopener noreferrer"
            className="ml-1 text-blue-600 hover:underline"
          >
            Download here
          </a>
        </div>
      </div>
      
      {/* Admin Verification Path - Only shown to users with VERIFIER_ROLE */}
      {hasVerifierRole && (
        <div className="p-4 border border-blue-200 rounded-lg bg-blue-50">
          <h2 className="text-xl font-semibold mb-4">Admin Verification (Testing Only)</h2>
          <p className="mb-4 text-sm text-gray-600">
            As an admin with VERIFIER_ROLE, you can directly verify users without requiring QR scanning.
          </p>
          
          <div className="flex flex-col space-y-2">
            <div className="flex gap-2">
              <input
                type="text"
                value={targetAddress}
                onChange={(e) => setTargetAddress(e.target.value)}
                placeholder="Enter wallet address to verify"
                className="flex-1 p-2 border rounded"
              />
              <button
                onClick={handleAdminVerify}
                disabled={isMockVerifying || !targetAddress}
                className={`px-4 py-2 rounded ${
                  isMockVerifying ? 'bg-gray-400' : 'bg-blue-600 hover:bg-blue-700'
                } text-white`}
              >
                {isMockVerifying ? "Verifying..." : "Verify Address"}
              </button>
            </div>
            
            <button
              onClick={() => {
                if (address) {
                  mockVerify({ args: [address] });
                  setTimeout(() => refetchVerification(), 3000);
                }
              }}
              className="w-full p-2 bg-gray-100 hover:bg-gray-200 rounded text-sm"
            >
              Verify My Own Address
            </button>
          </div>
          
          <div className="mt-4 text-xs text-red-500">
            Note: This admin verification option should be disabled or hidden in production environments.
          </div>
        </div>
      )}
    </div>
  );
};

export default IdentityVerification;
```

#### Configuration for Admin Verification Path

1. **Environment-based Controls**:
   ```typescript
   // In your .env.local file
   NEXT_PUBLIC_ENABLE_ADMIN_VERIFICATION=true  # Set to false in production
   ```

2. **Production Mode Control**:
   ```tsx
   {hasVerifierRole && (process.env.NODE_ENV !== 'production' || process.env.NEXT_PUBLIC_ENABLE_ADMIN_VERIFICATION === 'true') && (
     // Admin verification UI
   )}
   ```

#### Security Considerations

1. **Role-Based Access**: Always ensure only users with `VERIFIER_ROLE` can access the direct verification path.

2. **Environment Protection**: Consider disabling the admin verification completely in production environments.

3. **Audit Trail**: Implement logging for all admin verifications to maintain an audit trail.

4. **UI Separation**: Clearly separate user flows to prevent confusion:
   - Normal users should only see the QR code verification flow
   - Admin users should see both options with clear labeling

5. **Default to Secure Path**: Even for admins, make the QR code scanning the default/recommended option, with direct verification presented as a secondary choice.

## Common Use Cases

### Case 1: Complete User Flow with Identity Verification

1. User connects wallet
2. User completes Self identity verification (if not already verified)
3. User stakes ETH in StakingPool (call `stake` function)
4. User uses eco-friendly cup and uploads photo for verification
5. Backend verifies the photo and calls `recordVerification`
6. User completes 3 verifications in a day
7. User claims reward (call `distributeReward` function)

### Case 2: Check User Verification Progress

1. Get user's identity verification status (call `isIdentityVerified` function)
2. If verified, get today's verification count (call `getVerificationCount` function)
3. Check if user can claim reward (call `canClaimReward` function)
4. Calculate user's potential reward amount (call `calculateReward` function)
5. Display user's token balance (call `balanceOf` function)

### Case 3: Admin Testing Flow

For development and testing purposes:

1. Admin connects wallet with `VERIFIER_ROLE`
2. Admin uses `mockIdentityVerification` to mark test users as verified
3. Admin can test the verification and reward distribution process
4. For production, remove any UI that allows calling the mock function

### Case 4: Withdraw Staked ETH

1. Get user's staked amount (call `getStakedAmount` function)
2. User specifies amount to withdraw
3. Call `withdraw` function to withdraw ETH
4. Listen to `Withdrawn` event to confirm withdrawal success

## Wagmi Usage Notes

When interacting with these contracts using Wagmi library, please note:

1. All amounts should be considered in terms of ETH's 18 decimal places
2. User must complete identity verification before participating in cup verifications
3. User must complete 3 verifications daily to claim reward
4. Platform token (EcoCupToken) minting can only be executed by RewardController contract
5. Verification records can only be called by addresses with VERIFIER_ROLE
6. Minimum staked amount is 0.0001 ETH
7. Reward calculation based on user's staked ETH amount and current APR
8. Default APR is 5% (represented as 500 in base 10000)

### Contract ABI

You can also view verified contract ABI on CeloScan:
- EcoCupToken: [https://alfajores.celoscan.io/address/0x098C568b8EFd867E089D130504d6CE9218519Dc2](https://alfajores.celoscan.io/address/0x098C568b8EFd867E089D130504d6CE9218519Dc2)
- VerificationRegistry: [https://alfajores.celoscan.io/address/0xF7C7a89e994a96C227E5911326aCdd5324261Fa3](https://alfajores.celoscan.io/address/0xF7C7a89e994a96C227E5911326aCdd5324261Fa3)
- SelfVerification: [https://alfajores.celoscan.io/address/0x73a166998f24878c7d1Dd55230A9281AAfEb43C8](https://alfajores.celoscan.io/address/0x73a166998f24878c7d1Dd55230A9281AAfEb43C8)
- RewardController: [https://alfajores.celoscan.io/address/0x3eA8E0860008fE95E22F2fb68728f40918Eed89E](https://alfajores.celoscan.io/address/0x3eA8E0860008fE95E22F2fb68728f40918Eed89E)
- StakingPool: [https://alfajores.celoscan.io/address/0x6075431B8eB46fc86c100b44eD669766363e76E6](https://alfajores.celoscan.io/address/0x6075431B8eB46fc86c100b44eD669766363e76E6) 