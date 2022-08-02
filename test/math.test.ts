import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { ethers } from 'hardhat';

import { deploy } from './utils';

import { TestMath } from '../typechain-types';

const { parseEther } = ethers.utils;

const SCALAR = parseEther('1');

async function deployFixture() {
  const math: TestMath = await deploy('TestMath');

  return { math };
}

describe('MathLib', function () {
  describe('function: fmul', function () {
    it('reverts if it overflows', async () => {
      const { math } = await loadFixture(deployFixture);
      await expect(math.fmul(ethers.constants.MaxUint256.div(2).add(1), 2)).to
        .be.reverted;
    });

    it('does fixed point multiplication', async () => {
      const { math } = await loadFixture(deployFixture);

      expect(await math.fmul(parseEther('10'), parseEther('2.5'))).to.be.equal(
        parseEther('10').mul(parseEther('2.5')).div(SCALAR)
      );
    });
  });

  describe('function: fdiv', function () {
    it('reverts if it overflows', async () => {
      const { math } = await loadFixture(deployFixture);
      await expect(math.fdiv(ethers.constants.MaxUint256.div(2), 2)).to.be
        .reverted;
    });

    it('does fixed point division', async () => {
      const { math } = await loadFixture(deployFixture);

      expect(await math.fdiv(parseEther('10'), parseEther('2.5'))).to.be.equal(
        parseEther('10').mul(SCALAR).div(parseEther('2.5'))
      );
    });
  });

  it('adjusts a number to have 18 decimals', async () => {
    const { math } = await loadFixture(deployFixture);

    const x = 987_654_321;

    // Adds 10 decimal houses
    expect(await math.adjust(x, 8)).to.be.equal(parseEther('9.87654321'));

    // Does not change the number as it is a WAD
    expect(await math.adjust(parseEther('10'), 18)).to.be.equal(
      parseEther('10')
    );

    // Does not change the number as it is a WAD
    expect(await math.adjust(parseEther('10'), 20)).to.be.equal(
      parseEther('0.1')
    );

    // Overflow protection
    await expect(math.adjust(ethers.constants.MaxUint256, 17)).to.reverted;

    // Underflow protection
    expect(await math.adjust(10_000, 27)).to.be.equal(0);
  });

  it('selects the lowest value', async () => {
    const { math } = await loadFixture(deployFixture);
    expect(await math.min(SCALAR, parseEther('2'))).to.be.equal(SCALAR);

    expect(
      await math.min(parseEther('105.5'), parseEther('105.49'))
    ).to.be.equal(parseEther('105.49'));

    expect(
      await math.min(parseEther('105.5'), parseEther('105.5'))
    ).to.be.equal(parseEther('105.5'));
  });

  it('squares roots a number', async () => {
    const { math } = await loadFixture(deployFixture);

    expect(
      await math.sqrt(ethers.BigNumber.from('82726192028263'))
    ).to.be.equal(9_095_394);
  });

  it('multiplies and divides with shadow overflow protection', async () => {
    const { math } = await loadFixture(deployFixture);

    expect(
      await math.mulDiv(parseEther('182726'), parseEther('2918'), 10 ** 6)
    ).to.be.equal(parseEther('182726').mul(parseEther('2918')).div(1e6));

    expect(
      await math.mulDiv(ethers.constants.MaxUint256.div(2).add(1), 2, 2)
    ).to.be.equal(ethers.constants.MaxUint256.div(2).add(1));
  });

  it('performs unchecked addition', async () => {
    const { math } = await loadFixture(deployFixture);

    expect(await math.uAdd(ethers.constants.MaxUint256, 1)).to.be.equal(0);
    expect(await math.uAdd(parseEther('1'), parseEther('3'))).to.be.equal(
      parseEther('4')
    );
  });

  it('performs unchecked substitution', async () => {
    const { math } = await loadFixture(deployFixture);

    expect(await math.uSub(0, 1)).to.be.equal(ethers.constants.MaxUint256);
    expect(await math.uSub(parseEther('4'), parseEther('3'))).to.be.equal(
      parseEther('1')
    );
  });
});
