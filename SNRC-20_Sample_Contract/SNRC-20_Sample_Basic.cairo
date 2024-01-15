use starknet::ContractAddress;

#[starknet::interface]
trait ISNRC-20<TContractState> {
    fn deploy(ref self: TContractState, deploy_hash: felt252, mint_hash: felt252, transfer_hash: felt252, tick: felt252, max: u128, lim: u128);
    fn mint(ref self: TContractState, mint_hash: felt252, amount: u128);
    fn transfer(ref self: TContractState, transfer_hash: felt252, recipient: ContractAddress, amount: u128);
}

#[starknet::contract]
mod SNRC-20 {
    use core::zeroable::Zeroable;
    use core::traits::TryInto;
    use core::serde::Serde;
    use array::ArrayTrait;
    use starknet::{
        send_message_to_l1_syscall, EthAddress, EthAddressIntoFelt252, EthAddressSerde,
        ContractAddress, get_caller_address,
    };

    #[storage]
    struct Storage {
    }

    #[abi(embed_v0)]
    impl SNRC-20Impl of super::ISNRC-20<ContractState> {
        fn deploy(ref self: ContractState, deploy_hash: felt252, mint_hash: felt252, transfer_hash: felt252, tick: felt252, max: u128, lim: u128) {
            assert(tick.is_non_zero(), 'Invalid tick');
            assert(max > 0, 'Invalid max');
            assert(lim > 0, 'Invalid lim');

            let mut payload = ArrayTrait::new();
            deploy_hash.serialize(ref payload);
            mint_hash.serialize(ref payload);
            transfer_hash.serialize(ref payload);
            tick.serialize(ref payload);
            max.serialize(ref payload);
            lim.serialize(ref payload);

            let to_address: EthAddress = 0_u256.into();

            send_message_to_l1_syscall(to_address.into(), payload.span());
        }

        fn mint(ref self: ContractState, mint_hash: felt252, amount: u128) {
            let mut payload = ArrayTrait::new();
            mint_hash.serialize(ref payload);
            amount.serialize(ref payload);
            let to_address: EthAddress = 0_u256.into();
            send_message_to_l1_syscall(to_address.into(), payload.span());
        }

        fn transfer(
            ref self: ContractState, transfer_hash: felt252, recipient: ContractAddress, amount: u128
        ) {
            let sender = get_caller_address();
            assert(sender != recipient, 'Self transfer');
            if (amount == 0) {
                return;
            }

            let mut payload = ArrayTrait::new();
            transfer_hash.serialize(ref payload);
            recipient.serialize(ref payload);
            amount.serialize(ref payload);
            let to_address: EthAddress = 0_u256.into();
            send_message_to_l1_syscall(to_address.into(), payload.span());
        }

    }

}
