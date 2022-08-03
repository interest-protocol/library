// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../SafeTransferLib.sol";
import "../SafeTransferErrors.sol";

import "./MintableERC20.sol";

contract TestSafeTransfer is SafeTransferErrors {
    using SafeTransferLib for address;

    function transfer(
        address token,
        address to,
        uint256 amount
    ) external {
        token.safeTransfer(to, amount);
    }

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) external {
        token.safeTransferFrom(from, to, amount);
    }

    function approve(
        address token,
        address account,
        uint256 amount
    ) external {
        token.safeApprove(account, amount);
    }

    function approvev2(
        FalseERC20 token,
        address account,
        uint256 amount
    ) external {
        token.approvev2(account, amount);
    }

    function sendValue(address to, uint256 amount) external {
        to.safeTransferNativeToken(amount);
    }

    receive() external payable {}
}
