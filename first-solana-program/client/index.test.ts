import { Connection, Keypair, LAMPORTS_PER_SOL, PublicKey, SystemProgram, Transaction } from '@solana/web3.js';
import { expect, test } from 'bun:test';
import { intialData, schema } from './types';
import * as borsh from 'borsh';

const adminKeypair = Keypair.generate();
const dataAccount = Keypair.generate();

const programId = new PublicKey("5zZ8WrABmrSWjh5ydSV9tQN3oWXXKVj1DFFeZucKq41P");
const connection = new Connection("http://localhost:8899");

test("Account is initialized", async () => {

    const txns = await connection.requestAirdrop(adminKeypair.publicKey, 10 * LAMPORTS_PER_SOL);
    await connection.confirmTransaction(txns);

    const lamports = await connection.getMinimumBalanceForRentExemption(intialData);

    const instruction = SystemProgram.createAccount({
        fromPubkey: adminKeypair.publicKey,
        lamports,
        newAccountPubkey: dataAccount.publicKey,
        programId,
        space: intialData
    });

    const transaction = new Transaction();
    transaction.add(instruction);

    const signature = await connection.sendTransaction(transaction, [adminKeypair, dataAccount]);
    await connection.confirmTransaction(signature);

    console.log(dataAccount.publicKey.toBase58());

    const dataAccountInfo = await connection.getAccountInfo(dataAccount.publicKey);
    const counter = borsh.deserialize(schema, dataAccountInfo?.data);

    console.log("Counter is ", counter.count)
    expect(counter.count).toBe(0);
})


test("increase the counter", async () => {
      
})