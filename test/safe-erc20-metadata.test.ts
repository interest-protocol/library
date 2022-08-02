import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { ethers } from 'hardhat';

import { multiDeploy } from './utils';

import { TestSafeERC20Metadata } from '../typechain-types';
import { MintableERC20 } from '../typechain-types/contracts/test/MintableERC20';

async function deployFixture() {
  const [owner] = await ethers.getSigners();

  const [sut, token] = (await multiDeploy(
    ['TestSafeERC20Metadata', 'MintableERC20'],
    [[], ['M', 'M']]
  )) as [TestSafeERC20Metadata, MintableERC20];

  return { sut, token, owner };
}

describe('SafeTransferERC20Metadata', function () {
  it('returns ??? if we the address does not have a symbol', async () => {
    const { sut, owner } = await loadFixture(deployFixture);
    expect(await sut.symbol(owner.address)).to.be.equal('???');
  });

  it('returns the symbol of an ERC20', async () => {
    const { sut, token } = await loadFixture(deployFixture);
    expect(await sut.symbol(token.address)).to.be.equal(await token.symbol());
  });

  it('returns 18 if the contract has no code or does not implement the decimals function', async () => {
    const { sut, owner } = await loadFixture(deployFixture);
    expect(await sut.decimals(owner.address)).to.be.equal(18);
  });

  it('returns the token decimals', async () => {
    const { sut, token } = await loadFixture(deployFixture);
    expect(await sut.decimals(token.address)).to.be.equal(
      await token.decimals()
    );
  });
});
