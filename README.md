# FitNest
A decentralized fitness app focused on home workouts with minimal equipment, built on the Stacks blockchain.

## Features
- Create and manage workout programs
- Track workout completion and achievements
- Earn fitness tokens (FIT) for completing workouts
- Share and rate workout programs
- Leaderboard system

## Setup and Installation
1. Clone the repository
2. Install Clarinet (if not already installed)
3. Run `clarinet check` to verify the contract
4. Run `clarinet test` to run the test suite

## Usage Examples
```clarity
;; Create a new workout program
(contract-call? .fitnest create-workout "Full Body HIIT" u30 u3)

;; Complete a workout
(contract-call? .fitnest complete-workout u1)

;; Check earned tokens
(contract-call? .fitnest get-user-tokens)
```

## Dependencies
- Clarity language
- Clarinet for testing and deployment
