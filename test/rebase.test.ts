import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { BigNumber } from 'ethers';

import { deploy } from './utils';

import { TestRebase } from '../typechain-types';

async function deployFixture() {
  const rebase: TestRebase = await deploy('TestRebase');

  return { rebase };
}

describe('Rebase', function () {
  it('function: toBase', async () => {
    const { rebase } = await loadFixture(deployFixture);

    expect(await rebase.toBase(100, true)).to.be.equal(100);
    expect(await rebase.toBase(101, false)).to.be.equal(101);

    await rebase.set(1000, 1000);

    expect(await rebase.toBase(450, true)).to.be.equal(450);
    expect(await rebase.toBase(450, false)).to.be.equal(450);

    await rebase.set(900, 1000);

    expect(await rebase.toBase(499, true)).to.be.equal(450);
    expect(await rebase.toBase(499, false)).to.be.equal(449);
  });

  it('function: toElastic', async () => {
    const { rebase } = await loadFixture(deployFixture);

    expect(await rebase.toElastic(100, true)).to.be.equal(100);
    expect(await rebase.toElastic(101, false)).to.be.equal(101);

    await rebase.set(1000, 1000);

    expect(await rebase.toElastic(450, true)).to.be.equal(450);
    expect(await rebase.toElastic(450, false)).to.be.equal(450);

    await rebase.set(900, 1000);

    expect(await rebase.toElastic(499, true)).to.be.equal(555);
    expect(await rebase.toElastic(499, false)).to.be.equal(554);
  });

  it('reverts if you pass a value higher than uint128 to add(uint256,bool)', async () => {
    const { rebase } = await loadFixture(deployFixture);

    await expect(rebase['add(uint256,bool)'](BigNumber.from(2).pow(128), true))
      .to.be.reverted;
  });

  it('function: add(uint256,bool)', async () => {
    const { rebase } = await loadFixture(deployFixture);

    await rebase['add(uint256,bool)'](1000, true);

    const value = await rebase.value();

    expect(value.base).to.be.equal(1000);
    expect(value.elastic).to.be.equal(1000);

    await rebase.set(900, 1000);

    await rebase['add(uint256,bool)'](499, true);

    const value2 = await rebase.value();

    expect(value2.base).to.be.equal(900 + 450);
    expect(value2.elastic).to.be.equal(1000 + 499);

    await rebase['add(uint256,bool)'](499, false);

    const value3 = await rebase.value();

    expect(value3.base).to.be.equal(900 + 450 + 449);
    expect(value3.elastic).to.be.equal(1000 + 499 + 499);
  });

  it('reverts if you pass a value higher than uint128 to add(uint256,bool)', async () => {
    const { rebase } = await loadFixture(deployFixture);

    await expect(rebase['sub(uint256,bool)'](BigNumber.from(2).pow(128), true))
      .to.be.reverted;
  });

  it('function: sub(uint256,bool)', async () => {
    const { rebase } = await loadFixture(deployFixture);

    await rebase.set(900, 1000);

    await rebase['sub(uint256,bool)'](449, false);

    const value = await rebase.value();

    expect(value.base).to.be.equal(900 - 449);
    expect(value.elastic).to.be.equal(1000 - 498);

    await rebase['sub(uint256,bool)'](449, true);

    const value2 = await rebase.value();

    expect(value2.base).to.be.equal(900 - 449 - 449);
    expect(value2.elastic).to.be.equal(1000 - 498 - 500);
  });

  it('reverts if you pass a value higher than uint128 to add(uint256,uint256)', async () => {
    const { rebase } = await loadFixture(deployFixture);

    await expect(rebase['add(uint256,uint256)'](BigNumber.from(2).pow(128), 0))
      .to.be.reverted;

    await expect(rebase['add(uint256,uint256)'](0, BigNumber.from(2).pow(128)))
      .to.be.reverted;
  });

  it('function: add(uin256,uint256)', async () => {
    const { rebase } = await loadFixture(deployFixture);

    await rebase['add(uint256,uint256)'](500, 900);

    const value = await rebase.value();

    expect(value.base).to.be.equal(500);
    expect(value.elastic).to.be.equal(900);

    await rebase['add(uint256,uint256)'](450, 870);

    const value2 = await rebase.value();

    expect(value2.base).to.be.equal(500 + 450);
    expect(value2.elastic).to.be.equal(900 + 870);
  });

  it('reverts if you pass a value higher than uint128 to add(uint256,uint256)', async () => {
    const { rebase } = await loadFixture(deployFixture);

    await expect(rebase['sub(uint256,uint256)'](BigNumber.from(2).pow(128), 0))
      .to.be.reverted;

    await expect(rebase['sub(uint256,uint256)'](0, BigNumber.from(2).pow(128)))
      .to.be.reverted;
  });

  it('function: sub(uint256,uint256)', async () => {
    const { rebase } = await loadFixture(deployFixture);

    await rebase.set(900, 1000);

    await rebase['sub(uint256,uint256)'](350, 400);

    const value = await rebase.value();

    expect(value.base).to.be.equal(900 - 350);
    expect(value.elastic).to.be.equal(1000 - 400);
  });

  it('function: addElastic', async () => {
    const { rebase } = await loadFixture(deployFixture);
    await expect(rebase.addElastic(BigNumber.from(2).pow(128))).to.reverted;

    await rebase.addElastic(1000);

    expect((await rebase.value()).elastic).to.be.equal(1000);

    await rebase.addElastic(350);

    expect((await rebase.value()).elastic).to.be.equal(1000 + 350);
  });

  it('function: subElastic', async () => {
    const { rebase } = await loadFixture(deployFixture);
    await expect(rebase.subElastic(BigNumber.from(2).pow(128))).to.reverted;

    await rebase.set(900, 1000);

    await rebase.subElastic(500);

    expect((await rebase.value()).elastic).to.be.equal(500);

    await rebase.subElastic(350);

    expect((await rebase.value()).elastic).to.be.equal(150);
  });
});
