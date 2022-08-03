// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Set of functions to safely fetch the name and decimals of an {ERC20}.
 * @dev We use solidity to optimize the gas consumption.
 */
library SafeERC20MetadataLib {
    /**
     * @notice It returns the symbol of an {ERC20}.
     * @dev If the token has no code, this function will return "???".
     * @param token The address of the {ERC20} token.
     * @return symbol The symbol of the {ERC20} token.
     */
    function safeSymbol(address token)
        internal
        view
        returns (string memory symbol)
    {
        assembly {
            /// Save the free memory pointer in memory.
            symbol := mload(0x40)

            // Save the function selector for symbol() on slot 0x00.
            mstore(
                0x00,
                0x95d89b4100000000000000000000000000000000000000000000000000000000
            )

            /// We do not save the returned data in memory because it contains unnecessary data.
            /// {staticcall} will return the length of the data, length of the string, and the string.
            /// We save the data on the free memory slot.
            pop(staticcall(gas(), token, 0x00, 0x04, symbol, 0x60))

            /// If {staticcall} returned no data, we will assign the symbol to "???".
            /// The symbol function is not part of the {ERC20} specification.
            if iszero(returndatasize()) {
                /// Store the length of "???" in slot free memory slot + 0x20.
                mstore(add(symbol, 0x20), 0x03)
                /// Store the string "???" in  HEX using ASCII encoding in slot free memory slot + 0x40.
                /// Free memory slot === data length
                /// Free memory slot + 0x20 === length of the string
                /// Free memory slot + 0x40 === the string
                mstore(
                    add(symbol, 0x40),
                    0x3f3f3f0000000000000000000000000000000000000000000000000000000000
                )
            }

            /// Save on slot 0x40 the new free memory slot.
            mstore(0x40, add(symbol, 0x60))
            /// Point symbol to the length of the string, which is the free memory slot + 0x20.
            symbol := add(symbol, 0x20)
        }
    }

    /**
     * @notice It returns the symbol of an {ERC20}.
     * @dev If the token has no code, this function will 18.
     * @param token The address of the {ERC20} token.
     * @return decimals The token decimals.
     */
    function safeDecimals(address token)
        internal
        view
        returns (uint256 decimals)
    {
        assembly {
            /// Save the free memory pointer in memory.
            let freeMemoryPoint := mload(0x40)

            // Save the function selector for decimals() on slot 0x00.
            mstore(
                0x00,
                0x313ce56700000000000000000000000000000000000000000000000000000000
            )

            /// Save the returned data on the free memory slot. We are expecting a number, so 0x20 is enough.
            pop(staticcall(gas(), token, 0x00, 0x04, freeMemoryPoint, 0x20))

            /// If {staticcall} returned no data, we assume the token has 18 decimals.
            /// The decimals function is not part of the {ERC20} specification.
            /// We save 18 to free memory slot.

            switch returndatasize()
            case 0 {
                decimals := 0x12
            }
            default {
                /// Assign decimals to the data saved in the free memory point slot.
                decimals := mload(freeMemoryPoint)

                /// Update the 0x40 slot to point to the previous free memory slot + 0x20.
                mstore(0x40, add(freeMemoryPoint, 0x20))
            }
        }
    }
}
