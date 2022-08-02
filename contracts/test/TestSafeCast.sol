// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../SafeCastLib.sol";

contract TestSafeCast {
    using SafeCastLib for uint256;

    function toUint128(uint256 x) external pure returns (uint128) {
        return x.toUint128();
    }

    function toUint96(uint256 x) external pure returns (uint96) {
        return x.toUint96();
    }

    function toUint64(uint256 x) external pure returns (uint64) {
        return x.toUint64();
    }
}
