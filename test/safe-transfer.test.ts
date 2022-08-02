import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { ethers } from 'hardhat';

import { multiDeploy } from './utils';

import {
  MintableERC20,
  ErrorERC20,
  FalseERC20,
  TestSafeTransfer,
} from '../typechain-types';

const { parseEther } = ethers.utils;

async function deployFixture() {
  const [owner, alice] = await ethers.getSigners();
  const [sut, token, errorToken, falseToken] = (await multiDeploy(
    ['TestSafeTransfer', 'MintableERC20', 'ErrorERC20', 'FalseERC20'],
    [[], ['M', 'M'], ['M', 'M'], ['M', 'M']]
  )) as [TestSafeTransfer, MintableERC20, ErrorERC20, FalseERC20];

  await Promise.all([
    token.mint(sut.address, parseEther('1000')),
    errorToken.mint(sut.address, parseEther('1000')),
    falseToken.mint(sut.address, parseEther('1000')),
    owner.sendTransaction({ to: sut.address, value: parseEther('10') }),
  ]);

  return { owner, token, errorToken, falseToken, sut, alice };
}

describe('SafeTransferLib', function () {
  it('function: transfer', async () => {
    const { sut, errorToken, falseToken, token, owner } = await loadFixture(
      deployFixture
    );

    await expect(
      sut.transfer(errorToken.address, owner.address, parseEther('1'))
    ).to.rejectedWith('TransferFailed()');

    await expect(
      sut.transfer(falseToken.address, owner.address, parseEther('1'))
    ).to.rejectedWith('TransferFailed()');

    expect(await token.balanceOf(owner.address)).to.be.equal(0);

    await expect(sut.transfer(token.address, owner.address, parseEther('1')))
      .to.emit(token, 'Transfer')
      .withArgs(sut.address, owner.address, parseEther('1'));

    expect(await token.balanceOf(owner.address)).to.be.equal(parseEther('1'));
  });

  it('function: transferFrom', async () => {
    const { sut, errorToken, falseToken, token, owner } = await loadFixture(
      deployFixture
    );

    await expect(
      sut.transferFrom(
        token.address,
        sut.address,
        owner.address,
        parseEther('1')
      )
    ).to.rejectedWith('TransferFromFailed()');

    await sut.approve(token.address, sut.address, ethers.constants.MaxUint256);

    await sut.approvev2(
      errorToken.address,
      owner.address,
      ethers.constants.MaxUint256
    );

    await sut.approvev2(
      falseToken.address,
      sut.address,
      ethers.constants.MaxUint256
    );

    await expect(
      sut.transferFrom(
        errorToken.address,
        sut.address,
        owner.address,
        parseEther('1')
      )
    ).to.rejectedWith('TransferFromFailed()');

    await expect(
      sut.transferFrom(
        falseToken.address,
        sut.address,
        owner.address,
        parseEther('1')
      )
    ).to.rejectedWith('TransferFromFailed()');

    await expect(
      sut.transferFrom(
        token.address,
        sut.address,
        owner.address,
        parseEther('1')
      )
    )
      .to.emit(token, 'Transfer')
      .withArgs(sut.address, owner.address, parseEther('1'));
  });

  it('gives allowance', async () => {
    const { sut, errorToken, falseToken, token, owner } = await loadFixture(
      deployFixture
    );

    expect(await token.allowance(sut.address, owner.address)).to.be.equal(0);
    await sut.approve(token.address, owner.address, 1000);
    expect(await token.allowance(sut.address, owner.address)).to.be.equal(1000);

    await expect(
      sut.approve(errorToken.address, owner.address, 1)
    ).to.rejectedWith('ApproveFailed');

    await expect(
      sut.approve(falseToken.address, owner.address, 1)
    ).to.rejectedWith('ApproveFailed');
  });

  it('transfers native token', async () => {
    const { sut, errorToken, owner, alice } = await loadFixture(deployFixture);

    await expect(
      sut.sendValue(errorToken.address, parseEther('1'))
    ).to.rejectedWith('NativeTokenTransferFailed()');

    await expect(
      sut.sendValue(errorToken.address, parseEther('100'))
    ).to.rejectedWith('NativeTokenTransferFailed()');

    const aliceBalance = await alice.getBalance();

    await sut.sendValue(alice.address, parseEther('1'));

    expect(await alice.getBalance()).to.be.equal(
      aliceBalance.add(parseEther('1'))
    );
  });
});
