use solana_program::{
    account_info::{AccountInfo, next_account_info},
    entrypoint,
    entrypoint::ProgramResult,
    program::invoke_signed,
    pubkey::Pubkey,
    system_instruction::create_account,
};

entrypoint!(process_instruction);

pub fn process_instruction(
    program_id: &Pubkey,
    accounts: &[AccountInfo],
    _data: &[u8], 
) -> ProgramResult {
    let mut iter = accounts.iter();

    let pda = next_account_info(&mut iter)?;
    let user_account = next_account_info(&mut iter)?;
    let _system_pro = next_account_info(&mut iter)?; // system_program

    // 1. Find the PDA and the bump
    let seeds = &[user_account.key.as_ref(), b"User"];
    let (_pda_key, bump) = Pubkey::find_program_address(seeds, program_id);

    // 2. Create the instruction
    let ix = create_account(user_account.key, pda.key, 1000000000, 8, program_id);

    // 3. Construct the signer seeds 
    let signer_seeds: &[&[u8]] = &[user_account.key.as_ref(), b"User", &[bump]];

    // 4. Invoke signed
    invoke_signed(&ix, accounts, &[signer_seeds])?;

    Ok(())
}
