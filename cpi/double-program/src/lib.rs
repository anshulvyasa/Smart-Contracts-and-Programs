use borsh::{BorshDeserialize, BorshSerialize};
use solana_program::{
    account_info::{AccountInfo, next_account_info},
    entrypoint::{ProgramResult},
    entrypoint,
    pubkey::Pubkey,
};

entrypoint!(process_instruction);

#[derive(BorshSerialize, BorshDeserialize)]
struct Counter {
    count: u32,
}

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    data: &[u8],
) -> ProgramResult {
    let mut iter = accounts.iter();

    let account = next_account_info(&mut iter)?;
    let mut counter = Counter::try_from_slice(&account.data.borrow())?;

    if counter.count == 0 {
        counter.count = 1;
    } else {
        counter.count *= 2;
    }

    counter.serialize(&mut *account.data.borrow_mut())?;

    Ok(())
}
