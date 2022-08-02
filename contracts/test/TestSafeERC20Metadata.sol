// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../SafeERC20MetadataLib.sol";
import "./MintableERC20.sol";

contract TestSafeERC20Metadata {
    using SafeERC20MetadataLib for address;

    function symbol(address token) external view returns (string memory) {
        return token.safeSymbol();
    }

    function decimals(address token) external view returns (uint256) {
        return token.safeDecimals();
    }
}
