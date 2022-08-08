// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

/**
 * @title Set of functions to safely cast uint256 numbers to smaller uint bit numbers.
 * @dev We use solidity to optimize the gas consumption, and the functions will revert without any reason.
 */
library SafeCastLib {
    /**
     * @notice Casts a uint256 to uint128 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint128
     * @return y The uint128 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**128 - 1
     */
    function toUint128(uint256 x) internal pure returns (uint128 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(128, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint112 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint112
     * @return y The uint112 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**128 - 1
     */
    function toUint112(uint256 x) internal pure returns (uint112 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(112, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint96 for memory optimization.
     *
     * @param x The uint256 that will be casted to uint96
     * @return y The uint96 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**96 - 1
     */
    function toUint96(uint256 x) internal pure returns (uint96 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(96, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint64 for memory optimization
     *
     * @param x The uint256 that will be casted to uint64
     * @return y The uint64 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**96 - 1
     */
    function toUint64(uint256 x) internal pure returns (uint64 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(64, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }

    /**
     * @notice Casts a uint256 to uint32 for memory optimization
     *
     * @param x The uint256 that will be casted to uint32
     * @return y The uint64 version of `x`
     *
     * @dev It will revert if `x` is higher than 2**96 - 1
     */
    function toUint32(uint256 x) internal pure returns (uint32 y) {
        //solhint-disable-next-line no-inline-assembly
        assembly {
            if gt(shr(32, x), 0) {
                revert(0, 0)
            }
            y := x
        }
    }
}
