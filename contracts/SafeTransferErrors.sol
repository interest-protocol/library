// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title The errors thrown by the {SafeERC20} library.
 * @dev Contracts that use the {SafeERC20} library should inherit this contract.
 */
contract SafeTransferErrors {
    error NativeTokenTransferFailed(); // function selector - keccak-256 0x3022f2e4

    error TransferFromFailed(); // function selector - keccak-256 0x7939f424

    error TransferFailed(); // function selector - keccak-256 0x90b8ec18

    error ApproveFailed(); // function selector - keccak-256 0x3e3f8f73
}
