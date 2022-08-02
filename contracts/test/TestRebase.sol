// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../RebaseLib.sol";

contract TestRebase {
    using RebaseLib for Rebase;

    Rebase public value;

    function set(uint128 base, uint128 elastic) external {
        value.base = base;
        value.elastic = elastic;
    }

    function toBase(uint256 elastic, bool roundUp)
        external
        view
        returns (uint256 base)
    {
        return value.toBase(elastic, roundUp);
    }

    function toElastic(uint256 base, bool roundUp)
        external
        view
        returns (uint256 elastic)
    {
        return value.toElastic(base, roundUp);
    }

    function add(uint256 elastic, bool roundUp) external {
        (value, ) = value.add(elastic, roundUp);
    }

    function sub(uint256 base, bool roundUp) external {
        (value, ) = value.sub(base, roundUp);
    }

    function add(uint256 base, uint256 elastic) external {
        value = value.add(base, elastic);
    }

    function sub(uint256 base, uint256 elastic) external {
        value = value.sub(base, elastic);
    }

    function addElastic(uint256 elastic) external returns (uint256 newElastic) {
        return value.addElastic(elastic);
    }

    function subElastic(uint256 elastic) external returns (uint256 newElastic) {
        return value.subElastic(elastic);
    }
}
