import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("Membership contract", function () {
  async function MembershipLockFixture() {
    const membership = await hre.viem.deployContract("Membership");
    await membership.write.setNumber([BigInt(0)]);

    return { membership };
  }

  it("Should increment the number correctly", async function () {
    const { membership } = await loadFixture(MembershipLockFixture);
    await membership.write.increment();
    expect(await membership.read.number()).to.equal(BigInt(1));
  });

  // This is not a fuzz test because Hardhat does not support fuzzing yet.
  it("Should set the number correctly", async function () {
    const { membership } = await loadFixture(MembershipLockFixture);
    await membership.write.setNumber([BigInt(100)]);
    expect(await membership.read.number()).to.equal(BigInt(100));
  });
});
