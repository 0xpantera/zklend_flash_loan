use starknet::ContractAddress;

#[starknet::interface]
pub trait IFlashLoanHandler<TContractState> {
    fn take_flash_loan(
        ref self: TContractState, 
        market_addr: ContractAddress, 
        token: ContractAddress, 
        amount: felt252, 
        return_amount: felt252
    );
}

#[starknet::contract]
mod FlashLoanHandler {
    use starknet::{ContractAddress, get_contract_address};
    use openzeppelin_token::erc20::interface::{
        IERC20Dispatcher, IERC20DispatcherTrait
    };
    use crate::interfaces::{
        IMarketDispatcher, IMarketDispatcherTrait, IZklendFlashCallback
    };

    // No storage needed
    #[storage]
    struct Storage {}

    // Serialize the callback params that will be sent as data to the flash loan function
    #[derive(Drop, Serde)]
    struct CallbackParams {
        token: ContractAddress,
        market_addr: ContractAddress,
        return_amount: felt252
    }

    #[abi(embed_v0)]
    impl IFlashLoanHandlerImpl of super::IFlashLoanHandler<ContractState> {
        // Request a flash loan
        fn take_flash_loan(
            ref self: ContractState, 
            market_addr: ContractAddress, 
            token: ContractAddress, 
            amount: felt252, 
            return_amount: felt252
        ) {
            // TODO: Implement this function 

            // TODO: Create the calldata for the callback
            let mut calldata = array![];
            Serde::<CallbackParams>::serialize(
                @CallbackParams { token, market_addr, return_amount }, 
                ref calldata
            );

            // TODO: Initiate a flash loan call to zkLend market
            IMarketDispatcher { contract_address: market_addr }
                .flash_loan(get_contract_address(), // receiver
                 token, // token
                 amount, // amount
                 calldata.span() // calldata
                );
        }
    }

    #[abi(embed_v0)]
    impl IZklendFlashCallbackImpl of IZklendFlashCallback<ContractState> {
        // Flash Loan Callback function
        fn zklend_flash_callback(ref self: ContractState, caller: ContractAddress, mut calldata: Span::<felt252>) {
            // TODO: Implement this function 

            // TODO: Implement some access control
            assert(caller == get_contract_address(), 'Unauthorized');

            // TODO: Deserialize the callback params
            let params = Serde::<CallbackParams>::deserialize(ref calldata)
                .expect('CANNOT_DECODE_PARAMS');

            // TODO: Transfer the return amount to the market
            IERC20Dispatcher { contract_address: params.token }
                .transfer(
                    params.market_addr, 
                    params.return_amount.into()
                );
        }
    }
}