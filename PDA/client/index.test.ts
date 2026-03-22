import { Keypair, LAMPORTS_PER_SOL, PublicKey, SystemProgram, Transaction, TransactionInstruction } from '@solana/web3.js';
import { describe, test, beforeAll, expect } from 'bun:test';
import { LiteSVM } from 'litesvm';
import * as path from 'path';

describe("Writing Test For The PDA Program", () => {
    let svm: LiteSVM;
    let program_address: PublicKey;
    let payer: Keypair;

    beforeAll(() => {
        svm = new LiteSVM();
        program_address = PublicKey.unique();
        payer = new Keypair();

        svm.addProgramFromFile(program_address, path.join(__dirname, "../program/target/deploy/program.so"));
        svm.airdrop(payer.publicKey, BigInt(100 * LAMPORTS_PER_SOL))
    })

    test("Testing Creation Of PDA", () => {
        const [pda, bump] = PublicKey.findProgramAddressSync([payer.publicKey.toBuffer(), Buffer.from("User")], program_address)

        const ix = new TransactionInstruction({
            programId: program_address,
            data: Buffer.from(""),
            keys: [
                { pubkey: pda, isSigner: false, isWritable: true },
                { pubkey: payer.publicKey, isSigner: true, isWritable: false },
                { pubkey: SystemProgram.programId, isSigner: false, isWritable: false }
            ]
        })

        const txn = new Transaction();
        txn.add(ix);
        txn.recentBlockhash = svm.latestBlockhash();

        txn.sign(payer);
        txn.feePayer = payer.publicKey;

        svm.sendTransaction(txn);
        expect(svm.getBalance(pda)).toBe(BigInt(LAMPORTS_PER_SOL));
    })

})