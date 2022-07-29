// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

library SafeERC20 {
    /*//////////////////////////////////////////////////////////////
                              CUSTOM ERRORS
    //////////////////////////////////////////////////////////////*/

    error NativeTokenTransferFailed(); // identifier keccak-256 0x3022f2e4

    error TransferFromFailed(); // identifier keccak-256 0x7939f424

    error TransferFailed(); // identifier keccak-256 0x90b8ec18

    error ApproveFailed(); // identifier keccak-256 0x3e3f8f73

    /*//////////////////////////////////////////////////////////////
                          NATIVE TOKEN OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransferNativeToken(address to, uint256 amount) internal {
        assembly {
            // Pass no calldata only value in wei
            // Save the return on slot 0x00 (scratch space)
            // Returns 1 if successful
            if iszero(call(gas(), to, amount, 0x00, 0x00, 0x00, 0x00)) {
                // Save function identifier on the first 4 bytes in slot 0x00
                mstore(
                    0x00,
                    0x3022f2e400000000000000000000000000000000000000000000000000000000
                )
                // Grab the first 4 bytes and revert
                revert(0x00, 0x04)
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    function safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // Keep the pointer in memory to restore it later
            let freeMemoryPointer := mload(0x40)

            // Save the arguments in memory to pass to {call} later
            // We will override the free memory pointer but we will restore it later

            // transfer(address,uint256) first 4 bytes 0x23b872dd
            mstore(
                0x00,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, to) // save address after first 4 bytes
            mstore(0x24, amount) // save amount after 36 bytes

            // First we call the {token} with 100 bytes of data starting from slot 0x00 to slot 0x44.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, it fails.
            // If the data returned from {call} is not 1 or empty, it fails.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
                )
            ) {
                // Save function identifier for {TransferFailed()}
                mstore(
                    0x00,
                    0x90b8ec1800000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes and return
                revert(0x00, 0x04)
            }

            // restore the free memory pointer
            mstore(0x40, freeMemoryPointer)
        }
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // Keep the pointer in memory to restore it later
            let freeMemoryPointer := mload(0x40)

            // Save the arguments in memory to pass to {call} later
            // We will override the zero slot and free memory pointer BUT we will restore it after

            // transferFrom(address,address,uint256) first 4 bytes 0x23b872dd
            mstore(
                0x00,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, from) // save address after first 4 bytes
            mstore(0x24, to) // save address after 36 bytes
            mstore(0x44, amount) // save amount after 68 bytes

            // First we call the {token} with 100 bytes of data starting from slot 0x00 to slot 0x64.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, it fails.
            // If the data returned from {call} is not 1 or empty, it fails.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x64, 0x00, 0x20)
                )
            ) {
                // Save function identifier for {TransferFromFailed()}
                mstore(
                    0x00,
                    0x7939f42400000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes and return
                revert(0x00, 0x04)
            }

            // Clean up memory
            mstore(0x40, freeMemoryPointer) // restore the free memory pointer
            mstore(
                0x60,
                0x0000000000000000000000000000000000000000000000000000000000000000
            ) // restore the slot zero
        }
    }

    function safeApprove(
        address token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // Keep the pointer in memory to restore it later
            let freeMemoryPointer := mload(0x40)

            // Save the arguments in memory to pass to {call} later
            // We will override the free memory pointer but we will restore it later

            // approve(address,uint256) first 4 bytes 0xa095ea7b3
            mstore(
                0x00,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, to) // save address after first 4 bytes
            mstore(0x24, amount) // save amount after 36 bytes

            // First we call the {token} with 100 bytes of data starting from slot 0x00 to slot 0x44.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, it fails.
            // If the data returned from {call} is not 1 or empty, it fails.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
                )
            ) {
                // Save function identifier for {ApproveFailed()}
                mstore(
                    0x00,
                    0x3e3f8f7300000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes and return
                revert(0x00, 0x04)
            }

            // restore the free memory pointer
            mstore(0x40, freeMemoryPointer)
        }
    }
}
