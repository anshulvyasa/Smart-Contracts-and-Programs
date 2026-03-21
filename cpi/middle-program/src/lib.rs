use solana_program::{
    account_info::{AccountInfo, next_account_info},
    address_lookup_table::instruction,
    entrypoint,
    entrypoint::ProgramResult,
    instruction::{AccountMeta, Instruction},
    program::invoke,
    pubkey::Pubkey,
};

entrypoint!(process_instruction);

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    data: &[u8],
) -> ProgramResult {
    let mut iter = accounts.iter();

    let data_account = next_account_info(&mut iter)?;
    let double_program_info = next_account_info(&mut iter)?;

    let instruction = Instruction {
        program_id: *double_program_info.key,
        data: vec![],
        accounts: vec![AccountMeta {
            is_signer: false,
            is_writable: true,
            pubkey: *data_account.key,
        }],
    };

    invoke(&instruction, &[data_account.clone()]);

    Ok(())
}
