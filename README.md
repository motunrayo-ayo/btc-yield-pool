# Staked BTC Smart Contract

## Overview

This smart contract implements a BTC staking and yield generation mechanism on the Stacks blockchain using Clarity. It provides a comprehensive solution for users to stake their BTC, earn yield, and manage their staked assets with built-in security features and risk management.

## Features

### Core Functionalities

- BTC Staking
- Yield Generation
- Rewards Claiming
- Token Transfer
- Risk Scoring
- Optional Insurance Coverage

### Key Characteristics

- Compliant with SIP-010 Token Standard
- Configurable Yield Rates
- Minimum Stake Enforcement
- Owner-controlled Pool Management
- Detailed Event Logging

## Contract Constants

### Stake Parameters

- **Minimum Stake Amount**: 0.01 BTC (1,000,000 sats)
- **Maximum Yield Rate**: 50% APY
- **Base APY**: 5%
- **Blocks per Day**: 144

### Token Details

- **Name**: Staked BTC
- **Symbol**: stBTC
- **Decimals**: 8

## Functions

### Staking Functions

- `stake(amount)`: Deposit BTC into the staking pool
- `unstake(amount)`: Withdraw staked BTC from the pool
- `claim-rewards()`: Claim accumulated yield rewards

### Pool Management Functions

- `initialize-pool(initial-rate)`: Set up and activate the staking pool
- `distribute-yield()`: Distribute yield across staked assets
- `set-token-uri(new-uri)`: Update contract's token URI

### Read-Only Functions

- `get-staker-balance(staker)`: Check individual staker's balance
- `get-staker-rewards(staker)`: Retrieve pending rewards
- `get-pool-stats()`: View comprehensive pool statistics
- `get-risk-score(staker)`: Check a staker's risk profile

## Security Measures

### Error Handling

The contract includes comprehensive error constants to manage various edge cases:

- Owner-only function restrictions
- Pool initialization checks
- Stake amount validations
- Balance and transfer restrictions

### Risk Management

- Dynamic risk scoring for stakers
- Optional insurance coverage mechanism
- Yield distribution rate limits

## Risk Considerations

### Staking Risks

- Yield rates are variable
- Minimum stake requirements
- Potential for yield fluctuations

### Technical Risks

- Smart contract dependencies
- Blockchain network conditions
- Potential smart contract vulnerabilities

## Deployment Requirements

### Development Environment

- Clarinet v2.7.0+
- Stacks Blockchain Compatible Environment

### Recommended Setup

1. Install Clarinet
2. Clone the repository
3. Configure deployment parameters
4. Run test suite
5. Deploy to desired network

## Usage Example

```clarity
;; Initialize the pool with a 5% yield rate
(initialize-pool u500)

;; Stake 1 BTC (100,000,000 sats)
(stake u100000000)

;; Claim accumulated rewards
(claim-rewards)
```

## Contribution Guidelines

1. Fork the repository
2. Create feature branches
3. Write comprehensive tests
4. Follow Clarity best practices
5. Submit pull requests with detailed descriptions
