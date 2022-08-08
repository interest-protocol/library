import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { ethers } from 'hardhat';
import { BigNumber } from 'ethers';
import { deploy } from './utils';

import { TestSafeCast } from '../typechain-types';

async function deployFixture() {
  const safeCast: TestSafeCast = await deploy('TestSafeCast');

  return { safeCast };
}

describe('SafeCastLib', function () {
  it('casts a uint256 to uint128', async () => {
    const { safeCast } = await loadFixture(deployFixture);
    expect(await safeCast.toUint128(100)).to.be.equal(100);
    expect(
      await safeCast.toUint128(BigNumber.from(2).pow(128).sub(1))
    ).to.be.equal(BigNumber.from(2).pow(128).sub(1));
    await expect(safeCast.toUint128(BigNumber.from(2).pow(128))).to.be.reverted;
  });

  it('casts a uint256 to uint112', async () => {
    const { safeCast } = await loadFixture(deployFixture);
    expect(await safeCast.toUint112(100)).to.be.equal(100);
    expect(
      await safeCast.toUint112(BigNumber.from(2).pow(112).sub(1))
    ).to.be.equal(BigNumber.from(2).pow(112).sub(1));
    await expect(safeCast.toUint112(BigNumber.from(2).pow(112))).to.be.reverted;
  });

  it('casts a uint256 to uint96', async () => {
    const { safeCast } = await loadFixture(deployFixture);
    expect(await safeCast.toUint96(100)).to.be.equal(100);
    expect(
      await safeCast.toUint96(BigNumber.from(2).pow(96).sub(1))
    ).to.be.equal(BigNumber.from(2).pow(96).sub(1));

    await expect(safeCast.toUint96(BigNumber.from(2).pow(96))).to.be.reverted;
  });

  it('casts a uint256 to uint64', async () => {
    const { safeCast } = await loadFixture(deployFixture);
    expect(await safeCast.toUint64(100)).to.be.equal(100);
    expect(
      await safeCast.toUint64(BigNumber.from(2).pow(64).sub(1))
    ).to.be.equal(BigNumber.from(2).pow(64).sub(1));

    await expect(safeCast.toUint64(BigNumber.from(2).pow(64))).to.be.reverted;
  });

  it('casts a uint256 to uint32', async () => {
    const { safeCast } = await loadFixture(deployFixture);
    expect(await safeCast.toUint32(100)).to.be.equal(100);
    expect(
      await safeCast.toUint32(BigNumber.from(2).pow(32).sub(1))
    ).to.be.equal(BigNumber.from(2).pow(32).sub(1));

    await expect(safeCast.toUint32(BigNumber.from(2).pow(32))).to.be.reverted;
  });
});
