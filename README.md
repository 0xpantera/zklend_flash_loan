# zkLend Flash Loan Handler Project

This project demonstrates how to interact with zkLend's flash loan functionality on Starknet. It provides a simple implementation of a contract that can take flash loans, utilize the borrowed funds, and repay them within the same transaction.

## Overview

The zkLend Flash Loan Handler demonstrates:

1. How to request a flash loan from the zkLend market
2. How to handle the callback when the flash loan is received
3. How to repay the flash loan with the appropriate fees

## Project Structure

- `src/flash_loan_handler.cairo`: Main contract implementation that handles flash loans
- `src/interfaces.cairo`: Contains interfaces for zkLend's contracts and other related protocols
- `tests/test_contract.cairo`: Test file that demonstrates the flash loan process

## How It Works

### Flash Loan Process

1. A user calls the `take_flash_loan` function on the FlashLoanHandler contract
2. The contract requests a flash loan from zkLend's market contract
3. zkLend transfers the requested tokens to the FlashLoanHandler
4. zkLend calls back to the `zklend_flash_callback` function on the FlashLoanHandler
5. The FlashLoanHandler performs any operations with the borrowed funds
6. Before the callback completes, the FlashLoanHandler repays the loan plus fees
7. If repayment is successful, the transaction completes; otherwise, it reverts

### Key Components

- `take_flash_loan`: Initiates the flash loan process
- `zklend_flash_callback`: Handles the callback from zkLend and repays the loan
- `CallbackParams`: Struct to pass data between the loan request and callback

## Testing

The project includes a forked test that simulates taking a flash loan on Starknet mainnet:

1. Sets up test accounts and token balances
2. Deploys the FlashLoanHandler contract
3. Transfers fee amount to the FlashLoanHandler
4. Executes a flash loan for 100 USDC
5. Verifies the correct state after the loan is repaid

## Running the Tests

To run the tests:

```bash
scarb test
```

## Technical Details

- The flash loan fee on zkLend is 0.09% of the borrowed amount
- The test uses a mainnet fork at block 609051

## Dependencies

- starknet: 2.11.1
- openzeppelin_access: 1.0.0
- openzeppelin_token: 1.0.0
- snforge_std: 0.38.3 (for testing)
