import { expect } from "chai";
import { ethers } from "hardhat";
import { Film } from "../typechain-types";
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("Film Token", function () {
  let film: Film;
  let owner: SignerWithAddress;
  let spender: SignerWithAddress;
  let recipient: SignerWithAddress;

  beforeEach(async function () {
    [owner, spender, recipient] = await ethers.getSigners();
    
    const Film = await ethers.getContractFactory("Film");
    film = await Film.deploy(owner.address, owner.address);
    await film.waitForDeployment();
  });

  describe("permit and transfer", function () {
    it("should permit and transfer tokens using signature", async function () {
      const amount = ethers.parseEther("100");
      const nonce = await film.nonces(owner.address);
      const deadline = (await time.latest()) + 3600; // 1 hour from now
      
      // Get the EIP-712 digest
      const domain = {
        name: await film.name(),
        version: '1',
        chainId: (await ethers.provider.getNetwork()).chainId,
        verifyingContract: await film.getAddress()
      };

      const types = {
        Permit: [
          { name: 'owner', type: 'address' },
          { name: 'spender', type: 'address' },
          { name: 'value', type: 'uint256' },
          { name: 'nonce', type: 'uint256' },
          { name: 'deadline', type: 'uint256' }
        ]
      };

      const values = {
        owner: owner.address,
        spender: spender.address,
        value: amount,
        nonce: nonce,
        deadline: deadline
      };

      // Sign the permit
      const signature = await owner.signTypedData(domain, types, values);
      const sig = ethers.Signature.from(signature);

      // Use the permit
      await film.permit(
        owner.address,
        spender.address,
        amount,
        deadline,
        sig.v,
        sig.r,
        sig.s
      );

      // Verify allowance was set
      expect(await film.allowance(owner.address, spender.address)).to.equal(amount);

      // Transfer tokens using the approved allowance
      await film.connect(spender).transferFrom(owner.address, recipient.address, amount);

      // Verify balances
      expect(await film.balanceOf(recipient.address)).to.equal(amount);
    });

    it("should fail with expired deadline", async function () {
      const amount = ethers.parseEther("100");
      const nonce = await film.nonces(owner.address);
      const deadline = (await time.latest()) - 3600; // 1 hour in the past
      
      const domain = {
        name: await film.name(),
        version: '1',
        chainId: (await ethers.provider.getNetwork()).chainId,
        verifyingContract: await film.getAddress()
      };

      const types = {
        Permit: [
          { name: 'owner', type: 'address' },
          { name: 'spender', type: 'address' },
          { name: 'value', type: 'uint256' },
          { name: 'nonce', type: 'uint256' },
          { name: 'deadline', type: 'uint256' }
        ]
      };

      const values = {
        owner: owner.address,
        spender: spender.address,
        value: amount,
        nonce: nonce,
        deadline: deadline
      };

      const signature = await owner.signTypedData(domain, types, values);
      const sig = ethers.Signature.from(signature);

      // Attempt to use expired permit should fail
      await expect(film.permit(
        owner.address,
        spender.address,
        amount,
        deadline,
        sig.v,
        sig.r,
        sig.s
      )).to.be.reverted
    });
  });
});