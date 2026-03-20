import * as borsh from 'borsh';


export class AccountCounter {
    count: number;
    constructor({ count }: { count: number }) {
        this.count = count;
    }
}


export const schema: borsh.Schema = {
    struct: {
        count: 'u32'
    }
}

export const intialData=borsh.serialize(schema,new AccountCounter({count:1})).length;

