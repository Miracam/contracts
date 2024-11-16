import { expect } from "chai";
import { ethers } from "hardhat";
import { Delta, Beta, Evan } from "../typechain-types";
import ECDSA from 'ecdsa-secp256r1'

async function extract(pubkey: string, signature: string) {
    const pubKeyBuf = Buffer.from(pubkey, 'base64')
    const signatureBuffer = Buffer.from(signature, 'base64')

    const x = pubKeyBuf.subarray(1, 33)
    const y = pubKeyBuf.subarray(33)

    const [r, s] = derToRS(signatureBuffer)

    return { x, y, r, s }
}

function derToRS(der: Buffer) {
    let offset = 3;
    let dataOffset;

    if (der[offset] == 0x21) {
        dataOffset = offset + 2;
    }
    else {
        dataOffset = offset + 1;
    }
    const r = der.slice(dataOffset, dataOffset + 32);
    offset = offset + der[offset] + 1 + 1
    if (der[offset] == 0x21) {
        dataOffset = offset + 2;
    }
    else {
        dataOffset = offset + 1;
    }
    const s = der.slice(dataOffset, dataOffset + 32);
    return [r, s]
}

describe("Delta", function () {
    let delta: Delta;

    beforeEach(async function () {
        // Deploy the Delta contract
                
        const MiracamNFT = await ethers.getContractFactory("MiracamNFT");
        const miracamNFT = MiracamNFT.attach("0x4b79800e11fA527b01685056970D62878240Ea46") as MiracamNFT;


        const miracamNFTMinter = await ethers.deployContract("MiracamNftMinter", [miracamNFT.target, AttesterAddress]);
        await miracamNFTMinter.waitForDeployment();
        console.log("miracamNFTMinter deployed to:", await miracamNFTMinter.getAddress());

        const MINTER_ROLE = await miracamNFT.MINTER_ROLE()
        await miracamNFT.grantRole(MINTER_ROLE, miracamNFTMinter.target);

    });

    describe("mint", function () {
        it("should verify a valid signature", async function () {
            // Example test values - these should be replaced with actual P256 signature values
            //   const hash = ethers.utils.keccak256("0x1234");
            //   const r = ethers.BigNumber.from("1234567890");
            //   const s = ethers.BigNumber.from("9876543210");
            //   const x = ethers.BigNumber.from("2468101214");
            //   const y = ethers.BigNumber.from("1357911131");


            const proof =
            {
                "message": "owner=0x485fa1883a8ad8b09d69522a7f79162fc3eb8e80&url=https://devnet.irys.xyz/Hy2iM85af2poKdY59YhMhJviasEmKch6JspkRinaYR8G",
                "owner": "0x485fa1883a8ad8b09d69522a7f79162fc3eb8e80",
                "secp256r1_pubkey": "BALNspjpyeYwX9vArRtgHOOltyOYYMDDOiw3G6xiyAzEBrGfr6RXQp32J18GmvA+FifRGLGohYVdlisxZrPHD74=",
                "signature": "MEUCIQCMEZ7cBKAbBwqpNJ2w1uX8TESccJmL3Dn8BDFw1L3jWQIgE+OpfU3qsTlUP2JqMDVFKwojWJouQ6kUjtQqGrxb94w=",
                "url": "https://gateway.irys.xyz/CitxkaD3hLpTMaLkW1pagb1b6xPEtB6VvAjvfn6upyiZ"
            }

            // {
            //     "owner": "0x485fA1883A8ad8b09D69522A7f79162Fc3EB8E80",
            //     "url": "https://gateway.irys.xyz/EW2bRadrasSwaxzW1MfcAMYJmBbL1iGEwSHY2yCTJ5mJ",
            //     "message": "owner=0x485fA1883A8ad8b09D69522A7f79162Fc3EB8E80&url=https://gateway.irys.xyz/EW2bRadrasSwaxzW1MfcAMYJmBbL1iGEwSHY2yCTJ5mJ",
            //     "signature": "MEUCIQDuuDLwzFTqx7C/151hStGV2P1nfL8jmHfItOVob4LyhgIgCvHEFyvCsbqkZcf0ilv0Ux8sdZwcIKxvM9MFvJabO+Q=",
            //     "pubkey": "BALNspjpyeYwX9vArRtgHOOltyOYYMDDOiw3G6xiyAzEBrGfr6RXQp32J18GmvA+FifRGLGohYVdlisxZrPHD74=",
            //     "hash": "096e94afcef61c785b8209c3ca057cd5f30e3d7fd203ff1f4dc511de6bc259af"
            //   }
            //   const message = proof.message
            const { x, y, r, s } = await extract(proof.secp256r1_pubkey, proof.signature)

            // const url = "https://devnet.irys.xyz/FZu9y49SXAacUQ27uu3nfuUxidikZKGS2gQ3gL9JhJ11";
            // //   const message = "fd59e13bb74d845477fc8ee394d216d41c1904367bcda6bf729a89264c68ed66"
            // //   const signature = "MEQCIAs6fYaNRateYmvea8klc8KzWilMbjeBGitdmHBrv9kkAiBLNTpnM46C68mVQP4/eyyzk5Szf+IMY5vhfQzBQZ7pTw=="
            // //   const pubkey = "BFd13VX35oXWjJQsFR+fucU9UhwPAQadvkzfa+3z5GmldbKHyNXknLUT2mnCaqjFhR26v/yonBdhc0RU9JzCq4s="

            // const message = "d9fa3cdebe1393fe8bd672643942b124da65b4a83404c8de95e4afd511f48683"
            // const signature = "MEYCIQCvT6deTI/2ehmP+LXKBlvJXcUUFbgfOhsdi51XTQO9CgIhANIMKw2VaQETMzl9gLH2FrZavKE6cCKagpY3w+OTm7R1"
            // const pubkey = "BNo9j0OUYfsfIyAh7CN1yqWTExjYzvyVlw7lCsWOz7/hDuN+5N+tfY/q0ultN8yKzN0wAQmJpWhiqpcJGI6azjs="
            // const { x, y, r, s } = await extract(pubkey, signature)

            //  const hash = ethers.keccak256(message)
            // const hash = await crypto.subtle.digest("SHA-256", Buffer.from(proof.hash))

            // const extracted = {
            //     hash: "0x" + Buffer.from(hash).toString('hex'),
            //     x: "0x" + x.toString('hex'),
            //     y: "0x" + y.toString('hex'),
            //     r: "0x" + r.toString('hex'),
            //     s: "0x" + s.toString('hex'),
            //     pubkey: Buffer.from(pubkey, 'base64')
            // }
            // console.log(extracted)

            //  console.log(BigInt("0x" + Buffer.from(signature, 'base64').toString('hex')))

            const extracted = {
                // hash: "0x" + Buffer.from(hash).toString('hex'),
                // x: "0x" + x.toString('hex'),
                // y: "0x" + y.toString('hex'),
                r: "0x" + r.toString('hex'),
                s: "0x" + s.toString('hex'),
                pubkey: Buffer.from(proof.secp256r1_pubkey, 'base64')
            }
            // const to = ethers.getAddress("0x80a301ba2fb59c9a0e90616110bb39726643e1ce")
            // const uri = "https://example.com/token/1"
            // await delta.mint(extracted.hash, extracted.r, extracted.s, extracted.pubkey, to, url);
            await delta.mint(extracted.r, extracted.s, extracted.pubkey, proof.owner, proof.url);
            //   const result = await delta.verifySignature(extracted.hash, extracted.r, extracted.s, extracted.x, extracted.y, extracted.pubkey);
            //   
            // Note: This test will likely fail with these example values
            // You'll need to replace them with valid P256 signature components
            //   expect(result).to.equal(true);
        });

        // it.only("custom signature", async function () {

        //     const pubkey = Buffer.from("04aa80d4d43513952023a54c3c6dc8216244b3fd0a2ba7bee4b2aaff72933ff2e9d63f3ec5254c3f81d2e51903a5e3b2e05f9c5d7c65d44608ee746ed3bba47672Ay59HrhovZQBRWiC7V545f7WknTNEjTuNF9hhlcIYsCl", 'hex').toString('base64')
        //     const signature = Buffer.from("304402201c6edf533da960d889e4ac252c0a545c2e944395e074546125ccabe19506ca8c02206f63d6d9751317a0340fc62bbfa40ae051040a3ebdf911b20bcb342087b20db9", 'hex').toString('base64')
        //     const { x, y, r, s } = await extract(pubkey, signature)
        //     const message = "27f068a4e0742ff83d7758bd6144a890131ee9fb7373fb2b9c7afa99f0ef94f0"
        //     const to = ethers.getAddress("0x80a301ba2fb59c9a0e90616110bb39726643e1ce")
        //     const url = "https://devnet.irys.xyz/ZWopyQrLaLM9sjPY1D1UcqVcUEQ6GJYYPqsfBZsz3RJ"

        //     // {
        //     //     "url": "https://gateway.irys.xyz/3v6To64vFbB2LSxcxWw87TDvueHArnrNq8kXnjr2Q5vW",
        //     //     "message": "owner=0x485fA1883A8ad8b09D69522A7f79162Fc3EB8E80&url=https://gateway.irys.xyz/3v6To64vFbB2LSxcxWw87TDvueHArnrNq8kXnjr2Q5vW",
        //     //     "signature": "MEUCIFgVbyEFuLWIVwQ5eD+2npbdZQWY3d05DSZNlsaInS54AiEAgh3bfHelqgLE1XTH80JnUyW48tgd9Cnf1tLsmCkzhyI=",
        //     //     "secp256r1_pubkey": "BALNspjpyeYwX9vArRtgHOOltyOYYMDDOiw3G6xiyAzEBrGfr6RXQp32J18GmvA+FifRGLGohYVdlisxZrPHD74=",
        //     //     "owner": "0x485fA1883A8ad8b09D69522A7f79162Fc3EB8E80"
        //     //   }

        //     const hash = await crypto.subtle.digest("SHA-256", Buffer.from(message))
        //     const extracted = {
        //         hash: "0x" + Buffer.from(hash).toString('hex'),
        //         x: "0x" + x.toString('hex'), 
        //         y: "0x" + y.toString('hex'), 
        //         r: "0x" + r.toString('hex'), 
        //         s: "0x" + s.toString('hex'),
        //         pubkey: Buffer.from(pubkey, 'base64')
        //     } 

        //     //  console.log(extracted)
        //     // await delta.mint(extracted.hash, extracted.r, extracted.s, extracted.pubkey, to, url);
        //     await delta.mint(extracted.r, extracted.s, extracted.pubkey, to, url);

        // })

        // it("should reject an invalid signature", async function () {
        //   const hash = ethers.utils.keccak256("0x1234");
        //   const r = ethers.BigNumber.from("0");
        //   const s = ethers.BigNumber.from("0");
        //   const x = ethers.BigNumber.from("0");
        //   const y = ethers.BigNumber.from("0");

        //   const result = await delta.verifySignature(hash, r, s, x, y);
        //   expect(result).to.equal(false);
        // });
    });
});
