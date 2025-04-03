use snforge_std::{
    declare, ContractClassTrait, DeclareResultTrait,  start_cheat_caller_address, 
    stop_cheat_caller_address, store, map_entry_address
};
use starknet::ContractAddress;
use openzeppelin_token::erc20::interface::{IERC20Dispatcher, IERC20DispatcherTrait};
use zklend_flash_loan::flash_loan_handler::{
    IFlashLoanHandlerDispatcher, IFlashLoanHandlerDispatcherTrait
};

fn deploy_flashloan_handler() -> (ContractAddress, IFlashLoanHandlerDispatcher) {
    let contract_class = declare("FlashLoanHandler").unwrap().contract_class();

    // Deploy contract, and get the address
    let (address, _) = contract_class.deploy(@array![]).unwrap();
    return (address, IFlashLoanHandlerDispatcher { contract_address: address });
}

#[test]
#[fork("MAINNET_FORK_609051")]
fn test_starknet_protocols_3() {
    // Some addresses and values
    let alice: ContractAddress = 1.try_into().unwrap();
    let alice_felt = 1;
    let hundred_usdc: felt252 = 1000000 * 100;
    let hundred_usdc_uint: u256 = hundred_usdc.into();

    // USDC
    let usdc_address: ContractAddress = 
        0x053c91253bc9682c04929ca02ed00b3e423f6710d2ee7e0d5ebb06f3ecf368a8
        .try_into()
        .unwrap();
    let usdc_dispatcher = IERC20Dispatcher { contract_address: usdc_address };

    // Give Alice 100 USDC
    store(
        usdc_address, 
        map_entry_address(selector!("ERC20_balances"), array![alice_felt].span()), 
        array![hundred_usdc].span()
    );

    // ZkLend Market
    let zklend_market_address: ContractAddress = 
        0x04c0a5193d58f74fbace4b74dcf65481e734ed1714121bdc571da345540efa05
        .try_into()
        .unwrap();

    // Deploying Flash Loan Handler contract
    let (flashloan_handler_address, flashloan_handler_dispatcher) = deploy_flashloan_handler();

    // TODO: Take a flash loan using the flash loan handler contract, 
    // pay the flash loan fee

    // The fee is 0.09% of the borrowed amount
    let fee = hundred_usdc_uint * 9 / 10000;

    // Send the fee amount to the flash loan handler contract
    start_cheat_caller_address(usdc_address, alice);
    usdc_dispatcher.transfer(flashloan_handler_address, fee);
    stop_cheat_caller_address(usdc_address);

    // Take the flash loan
    start_cheat_caller_address(flashloan_handler_address, alice);
    let amount_to_return: felt252 = hundred_usdc + fee.try_into().unwrap();
    flashloan_handler_dispatcher.take_flash_loan(
        zklend_market_address, 
        usdc_address, 
        hundred_usdc, 
        amount_to_return
    );
    stop_cheat_caller_address(flashloan_handler_address);

    // State Verification
    // Ensure flash loan handler has 0 USDC in balance
    assert(usdc_dispatcher.balance_of(flashloan_handler_address) == 0, 'wrong balance on handler');
    assert(usdc_dispatcher.balance_of(alice) == hundred_usdc_uint - fee, 'wrong balance on alice');
}
