// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../Math.sol";

contract TestMath {
    using Math for uint256;

    function fmul(uint256 x, uint256 y) external pure returns (uint256 z) {
        z = x.fmul(y);
    }

    function fdiv(uint256 x, uint256 y) external pure returns (uint256 z) {
        z = x.fdiv(y);
    }

    function adjust(uint256 amount, uint8 decimals)
        external
        pure
        returns (uint256 z)
    {
        z = amount.adjust(decimals);
    }

    function uAdd(uint256 x, uint256 y) external pure returns (uint256 z) {
        z = x.uAdd(y);
    }

    function uSub(uint256 x, uint256 y) external pure returns (uint256 z) {
        z = x.uSub(y);
    }

    function mulDiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) external pure returns (uint256 result) {
        result = a.mulDiv(b, denominator);
    }

    function sqrt(uint256 x) external pure returns (uint256) {
        return x.sqrt();
    }

    function min(uint256 x, uint256 y) external pure returns (uint256) {
        return x.min(y);
    }
}
