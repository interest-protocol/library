// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SafeCastLib.sol";
import "./MathLib.sol";

/// @dev The elastic represents an arbitrary amount, while the base is the shares of said amount. We save the base and elastic as uint128 instead of uint256 to optimize gas consumption by storing them in one storage slot. A maximum number of 2**128-1 should be enough to cover most of the use cases.
struct Rebase {
    uint128 elastic;
    uint128 base;
}

/**
 * @title A set of functions to manage the change in numbers of tokens and to properly represent them in shares.
 * @dev This library provides a collection of functions to manipulate the base and elastic values saved in a Rebase struct. In a pool context, the percentage of tokens a user owns. The elastic value represents the current number of pool tokens after incurring losses or profits. The functions in this library will revert if the base or elastic goes over 2**1281. Therefore, it is crucial to keep in mind the upper bound limit number this library supports.
 */
library RebaseLib {
    using SafeCastLib for uint256;
    using MathLib for uint256;

    /**
     * @dev Calculates a base value from an elastic value using the ratio of a {Rebase} struct.
     * @param total A {Rebase} struct, which represents a base/elastic pair.
     * @param elastic The new base is calculated from this elastic.
     * @param roundUp Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return base The base value calculated from the elastic and total arguments.
     */
    function toBase(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (uint256 base) {
        if (total.elastic == 0) {
            base = elastic;
        } else {
            base = elastic.mulDiv(total.base, total.elastic);
            if (roundUp && base.mulDiv(total.elastic, total.base) < elastic) {
                base += 1;
            }
        }
    }

    /**
     * @dev Calculates the elastic value from a base value using the ratio of a {Rebase} struct.
     * @param total A {Rebase} struct, which represents a base/elastic pair.
     * @param base The returned elastic is calculated from this base.
     * @param roundUp  Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return elastic The elastic value calculated from the base and total arguments.
     *
     */
    function toElastic(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (uint256 elastic) {
        if (total.base == 0) {
            elastic = base;
        } else {
            elastic = base.mulDiv(total.elastic, total.base);
            if (roundUp && elastic.mulDiv(total.base, total.elastic) < base) {
                elastic += 1;
            }
        }
    }

    /**
     * @dev Calculates new elastic and base values to a {Rebase} pair by increasing the elastic value. This function maintains the ratio of the current {Rebase} pair.
     * @param total The {Rebase} struct that we will be adding the additional elastic value.
     * @param elastic The additional elastic value to add to a {Rebase} struct.
     * @param roundUp  Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return total The new {Rebase} struct.
     * @return base The additional base value that was added to the new {Rebase} struct.
     */
    function add(
        Rebase memory total,
        uint256 elastic,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 base) {
        base = toBase(total, elastic, roundUp);
        total.elastic += elastic.toUint128();
        total.base += base.toUint128();
        return (total, base);
    }

    /**
     * @dev Calculates new elastic and base values to a {Rebase} pair by decreasing the base value. This function maintains the ratio of the current {Rebase} pair.
     * @param total The {Rebase} struct that we will be adding the additional elastic value.
     * @param base The amount of base to subtract from the {Rebase} struct.
     * @param roundUp  Rounding logic due to solidity always rounding down. If this argument is true, the final value will always be rounded up.
     * @return total The new {Rebase} struct.
     * @return elastic The amount of elastic that was removed from the {Rebase} struct.
     */
    function sub(
        Rebase memory total,
        uint256 base,
        bool roundUp
    ) internal pure returns (Rebase memory, uint256 elastic) {
        elastic = toElastic(total, base, roundUp);
        total.elastic -= elastic.toUint128();
        total.base -= base.toUint128();
        return (total, elastic);
    }

    /**
     * @dev Adds a base and elastic value to a {Rebase} struct.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param base The value to be added to the `total.base`.
     * @param elastic The value to be added to the `total.elastic`.
     * @return total The new {Rebase} struct is calculated by adding the `base` and `elastic` values.
     */
    function add(
        Rebase memory total,
        uint256 base,
        uint256 elastic
    ) internal pure returns (Rebase memory) {
        total.base += base.toUint128();
        total.elastic += elastic.toUint128();
        return total;
    }

    /**
     * @dev Substracts a base and elastic value to a {Rebase} struct.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param base The `total.base` will be decreased by this value.
     * @param elastic The `total.elastic` will be decreased by this value.
     * @return total The new {Rebase} struct is calculated by decreasing the `base` and `elastic` values.
     */
    function sub(
        Rebase memory total,
        uint256 base,
        uint256 elastic
    ) internal pure returns (Rebase memory) {
        total.base -= base.toUint128();
        total.elastic -= elastic.toUint128();
        return total;
    }

    /**
     * @dev This function increases the elastic value of a {Rebase} pair. The `total` parameter is saved in storage. This function will update the global state of the caller contract.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param elastic The value to be added to the `total.elastic`.
     * @return newElastic The new elastic value after reducing `elastic` from `total.elastic`.
     */
    function addElastic(Rebase storage total, uint256 elastic)
        internal
        returns (uint256 newElastic)
    {
        newElastic = total.elastic += elastic.toUint128();
    }

    /**
     * @dev This function decreases the elastic value of a {Rebase} pair. The `total` parameter is saved in storage. This function will update the global state of the caller contract.
     * @param total This function will update the base and elastic values of this {Rebase} struct.
     * @param elastic The value to be removed to the `total.elastic`.
     * @return newElastic The new elastic value after reducing `elastic` from `total.elastic`.
     */
    function subElastic(Rebase storage total, uint256 elastic)
        internal
        returns (uint256 newElastic)
    {
        newElastic = total.elastic -= elastic.toUint128();
    }
}
