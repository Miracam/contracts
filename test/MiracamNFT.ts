import { expect } from "chai";
import { ethers, upgrades } from "hardhat";
import { MiracamNFT, MiracamNftMinter } from "../typechain-types";

const AttesterAddress = "0xD798A4aDe873E2D447b43Af34e11882efEd911B1";

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

describe("MiracamNFTMinter", function () {
    let miracamNFTMinter: any;
    
    beforeEach(async function () {
        // Deploy the Delta contract
                
        const MiracamNFT = await ethers.getContractFactory("MiracamNFT");
        const miracamNFT = MiracamNFT.attach("0x4b79800e11fA527b01685056970D62878240Ea46") as MiracamNFT;

        const MiracamNftMinter = await ethers.getContractFactory("MiracamNftMinter");
        miracamNFTMinter = await upgrades.deployProxy(MiracamNftMinter, [miracamNFT.target, AttesterAddress]);
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


            const proof = {
  "message": "owner=0xed3f8f972da9a0a3ffe13c0183d2326bcab969b3&url=https://gateway.irys.xyz/FztGVPqj2we61Fp8UBhnRJGDiayYpqihLsQAbCp2tMF4",
  "owner": "0xed3f8f972da9a0a3ffe13c0183d2326bcab969b3",
  "secp256r1_pubkey": "BGFVi/DhC12Vl/KqtWKdOptUNhxS/uJRUMvaNfWn9t3HGPrgUv4QqbO1056W94SzmAlF4gyUoptl85wuSPxGK7k=",
  "signature": "MEUCIGQeTVFyaNaRPD3u37smiEwWFNsXNIQvqPvl4aHM3U9KAiEAnsI1FbTt2sDVTfROfQ/3AQkdBg+33YA6dAKeLZRfh+A=",
  "url": "https://gateway.irys.xyz/FztGVPqj2we61Fp8UBhnRJGDiayYpqihLsQAbCp2tMF4"
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
            await miracamNFTMinter.mint(extracted.r, extracted.s, extracted.pubkey, proof.owner, proof.url);
            //   const result = await delta.verifySignature(extracted.hash, extracted.r, extracted.s, extracted.x, extracted.y, extracted.pubkey);
            //   
            // Note: This test will likely fail with these example values
            // You'll need to replace them with valid P256 signature components
            //   expect(result).to.equal(true);
        });

    });
});
