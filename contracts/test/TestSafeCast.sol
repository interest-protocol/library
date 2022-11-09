// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../SafeCastLib.sol";

contract TestSafeCast {
    using SafeCastLib for uint256;

    function toUint224(uint256 x) external pure returns (uint224) {
        return x.toUint224();
    }

    function toUint128(uint256 x) external pure returns (uint128) {
        return x.toUint128();
    }

    function toUint112(uint256 x) external pure returns (uint112) {
        return x.toUint112();
    }

    function toUint96(uint256 x) external pure returns (uint96) {
        return x.toUint96();
    }

    function toUint64(uint256 x) external pure returns (uint64) {
        return x.toUint64();
    }

    function toUint32(uint256 x) external pure returns (uint32) {
        return x.toUint32();
    }
}
