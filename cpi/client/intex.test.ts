import { Keypair, LAMPORTS_PER_SOL, PublicKey, SystemProgram, Transaction, TransactionInstruction } from '@solana/web3.js';
import { expect, test } from 'bun:test';
import { LiteSVM } from 'litesvm';
import * as path from 'path';
import * as borsh from 'borsh';

class Counter {
    count: number;
    constructor(properties: { count: number }) {
        this.count = properties.count;
    }
}

const CounterSchema: borsh.Schema = {
    struct: { count: 'u32' }
};

const deserializeBytes = (dataAccount: Uint8Array<ArrayBufferLike> | undefined) => {
    if (!dataAccount) return;

    const counter = borsh.deserialize(CounterSchema, Buffer.from(dataAccount)) as Counter;
    return counter;
}


test("Checking The Double Program", () => {
    // Step 1: Creating instance of Lite SVM(Solana Virtual Machine)
    const svm = new LiteSVM();

    // Step 2: Deploying The Program On svm and creating address for it
    const program_address = PublicKey.unique();
    svm.addProgramFromFile(program_address, path.join(__dirname, "../double-program/target/deploy/double_program.so"));

    // Step 3: Creating Payer and airdrop him some SOL and verifying if he got 100SOL
    const payer = new Keypair();
    svm.airdrop(payer.publicKey, BigInt(LAMPORTS_PER_SOL * 100));
    expect(svm.getBalance(payer.publicKey)).toBe(BigInt(100 * LAMPORTS_PER_SOL));

    //Step 4: Creating Data Account
    const dataAccount = new Keypair();

    const amount = svm.minimumBalanceForRentExemption(BigInt(4));
    const ix1 = SystemProgram.createAccount({
        fromPubkey: payer.publicKey,
        newAccountPubkey: dataAccount.publicKey,
        lamports: Number(amount),
        space: 4,
        programId: program_address         // Make Sure this Account is Owned By Program
    })

    const txn1 = new Transaction();
    txn1.add(ix1);
    txn1.recentBlockhash = svm.latestBlockhash();

    txn1.sign(payer, dataAccount);
    txn1.feePayer = payer.publicKey;

    svm.sendTransaction(txn1);

    // Step 5: Calling Program With Data Account for The First Time
    const ix2 = new TransactionInstruction({
        programId: program_address,
        data: Buffer.from(""),
        keys: [
            { pubkey: dataAccount.publicKey, isSigner: false, isWritable: true }
        ]
    })

    const txn2 = new Transaction();
    txn2.add(ix2);
    txn2.recentBlockhash = svm.latestBlockhash();

    txn2.sign(payer);
    txn2.feePayer = payer.publicKey;

    svm.sendTransaction(txn2);
    const data1 = deserializeBytes(svm.getAccount(dataAccount.publicKey)?.data);
    expect(data1?.count).toBe(1);

    // Step 6: Expire Blockhash (i.e means move to next blockhash to avoid same transaction as above)
    svm.expireBlockhash();

    // Step 7: Calling Program With Data Account for The Second Time
    const ix3 = new TransactionInstruction({
        programId: program_address,
        data: Buffer.from(""),
        keys: [
            { pubkey: dataAccount.publicKey, isSigner: false, isWritable: true }
        ]
    })

    const txn3 = new Transaction();
    txn3.add(ix3);
    txn3.recentBlockhash = svm.latestBlockhash();

    txn3.sign(payer);
    txn3.feePayer = payer.publicKey;

    svm.sendTransaction(txn3);
    const data2 = deserializeBytes(svm.getAccount(dataAccount.publicKey)?.data);
    expect(data2?.count).toBe(2);

})