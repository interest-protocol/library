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
            // Save the function selector for symbol() on slot 0x00.
            mstore(
                0x00,
                0x95d89b4100000000000000000000000000000000000000000000000000000000
            )

            /// We do not save the returned data in memory because it contains unnecessary data.
            /// {staticcall} will return the length of the data, length of the string, and the string.
            pop(staticcall(gas(), token, 0x00, 0x04, 0x00, 0x00))

            /// If {staticcall} returned no data, we will assign the symbol to "???".
            /// The symbol function is not part of the {ERC20} specification.
            switch returndatasize()
            case 0 {
                /// Store the length of "???" in slot 0x00.
                mstore(0x00, 0x03)
                /// Store the string "???" in  HEX using ASCII encoding in slot 0x20.
                mstore(
                    0x20,
                    0x3f3f3f0000000000000000000000000000000000000000000000000000000000
                )
            }
            default {
                /// Save the returned data on slot 0x00.
                /// Discard the first word returned by {staticall} because we know the length of the data is 0x20.
                /// Store the length of the string followed by the string.
                returndatacopy(0x00, 0x20, 0x40)
            }

            /// Assign symbol to length memory slot.
            symbol := 0x00
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
            // Save the function selector for decimals() on slot 0x00.
            mstore(
                0x00,
                0x313ce56700000000000000000000000000000000000000000000000000000000
            )

            /// Save the returned data on slot 0x00.
            pop(staticcall(gas(), token, 0x00, 0x04, 0x00, 0x20))

            /// If {staticcall} returned no data, we assume the token has 18 decimals.
            /// The decimals function is not part of the {ERC20} specification.
            switch returndatasize()
            case 0 {
                decimals := 18
            }
            default {
                decimals := mload(0x00)
            }
        }
    }
}
