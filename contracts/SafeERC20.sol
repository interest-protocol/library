// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title A set of utility functions to guarantee the finality of the ERC20 {transfer}, {transferFrom} and {approve} functions.
 * @author Jose Cerqueira <jose@interestprotocol.com>
 * @dev These functions do not check that the recipient has any code, and they will revert with custom errors available in the {SafeERC20Errors}. We also leave dirty bits in the scratch space of the memory 0x00 to 0x3f.
 */
library SafeERC20 {
    /*//////////////////////////////////////////////////////////////
                          NATIVE TOKEN OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice This function sends native tokens from the {msg.sender} to an address.
     * @param to The recipient of the `amount` of native tokens.
     * @param amount The number of native tokens to send to the `to` address.
     */
    function safeTransferNativeToken(address to, uint256 amount) internal {
        assembly {
            /// Pass no calldata only value in wei
            /// We do not save any data in memory.
            /// Returns 1, if successful
            if iszero(call(gas(), to, amount, 0x00, 0x00, 0x00, 0x00)) {
                // Save the function identifier in slot 0x00
                mstore(
                    0x00,
                    0x3022f2e400000000000000000000000000000000000000000000000000000000
                )
                /// Grab the first 4 bytes in slot 0x00 and revert with {NativeTokenTransferFailed()}
                revert(0x00, 0x04)
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                            ERC20 OPERATIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice It transfers {ERC20} tokens from {msg.sender} to an address.
     * @param token The address of the {ERC20} token.
     * @param to The address of the recipient.
     * @param amount The number of tokens to send.
     */
    function safeTransfer(
        address token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            /// Keep the pointer in memory to restore it later.
            let freeMemoryPointer := mload(0x40)

            /// Save the arguments in memory to pass to {call} later.
            /// IMPORTANT: We will override the free memory pointer, but we will restore it later.

            /// keccak-256 transfer(address,uint256) first 4 bytes 0xa9059cbb
            mstore(
                0x00,
                0xa9059cbb00000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, to) // save address after first 4 bytes
            mstore(0x24, amount) // save amount after 36 bytes

            // First, we call the {token} with 68 bytes of data starting from slot 0x00 to slot 0x44.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, it fails.
            // If the data returned from {call} does not equal to 1 or is not empty, this transaction will revert.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
                )
            ) {
                // Save the function identifier for {TransferFailed()} on slot 0x00.
                mstore(
                    0x00,
                    0x90b8ec1800000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes on slot 0x00 and revert.
                revert(0x00, 0x04)
            }

            // Restore the free memory pointer value on slot 0x40.
            mstore(0x40, freeMemoryPointer)
        }
    }

    /**
     * @notice It transfers {ERC20} tokens from a third party address to another address.
     * @dev This function requires the {msg.sender} to have an allowance equal to or higher than the number of tokens being transferred.
     * @param token The address of the {ERC20} token.
     * @param from The address that will have its tokens transferred.
     * @param to The address of the recipient.
     * @param amount The number of tokens being transferred.
     */
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    ) internal {
        assembly {
            /// Keep the pointer in memory to restore it later.
            let freeMemoryPointer := mload(0x40)

            /// Save the arguments in memory to pass to {call} later.
            /// IMPORTANT: We will override the zero slot and free memory pointer, BUT we will restore it after.

            /// Save the first 4 bytes 0x23b872dd of the keccak-256 transferFrom(address,address,uint256) on slot 0x00.
            mstore(
                0x00,
                0x23b872dd00000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, from) // save address after first 4 bytes
            mstore(0x24, to) // save address after 36 bytes
            mstore(0x44, amount) // save amount after 68 bytes

            // First we call the {token} with 100 bytes of data starting from slot 0x00.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, this transaction will revert.
            // If the data returned from {call} does not equal to 1 or is not empty, this transaction will revert.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x64, 0x00, 0x20)
                )
            ) {
                // Save function identifier for {TransferFromFailed()} on slot 0x00.
                mstore(
                    0x00,
                    0x7939f42400000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes on slot 0x00 and revert.
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

    /**
     * @notice It allows the {msg.sender} to update the allowance of an address.
     * @dev Developers have to keep in mind that this transaction can be front-run.
     * @param token The address of the {ERC20} token.
     * @param to The address that will have its allowance updated.
     * @param amount The new allowance.
     */
    function safeApprove(
        address token,
        address to,
        uint256 amount
    ) internal {
        assembly {
            // Keep the pointer in memory to restore it later.
            let freeMemoryPointer := mload(0x40)

            // Save the arguments in memory to pass to {call} later.
            // We will override the free memory pointer, but we will restore it later.

            // Save the first 4 bytes (0x095ea7b3) of the keccak-256 approve(address,uint256) function on slot 0x00.
            mstore(
                0x00,
                0x095ea7b300000000000000000000000000000000000000000000000000000000
            )
            mstore(0x04, to) // save the address after 4 bytes
            mstore(0x24, amount) // save the amount after 36 bytes

            // First we call the {token} with 68 bytes of data starting from slot 0x00.
            // We save the returned data on slot 0x00.
            // If the {call} returns 0, this transaction will revert.
            // If the data returned from {call} does not equal to 1 or is not empty, this transaction will revert.
            if iszero(
                and(
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x00, 0x44, 0x00, 0x20)
                )
            ) {
                // Save the first 4 bytes of the keccak-256 of {ApproveFailed()}
                mstore(
                    0x00,
                    0x3e3f8f7300000000000000000000000000000000000000000000000000000000
                )
                // Select first 4 bytes on slot 0x00 and return
                revert(0x00, 0x04)
            }

            // restore the free memory pointer
            mstore(0x40, freeMemoryPointer)
        }
    }
}
