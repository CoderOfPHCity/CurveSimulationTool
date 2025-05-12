// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "./MathUtils.sol";

/// @notice Pure library implementing Curve-style StableSwap invariant functions for a 2-coin pool.
library StableSwapMath {
    uint8 internal constant N_COINS = 2;
    uint256 internal constant A_PRECISION = 1;
    uint256 private constant MAX_LOOP_LIMIT = 256;

    function getD(uint256[2] memory xp, uint256 a) internal pure returns (uint256) {
        uint256 numTokens = 2; // fixed size now
        uint256 s;
        for (uint256 i = 0; i < numTokens; i++) {
            // s = s.add(xp[i]);
            s = s + xp[i];
        }
        if (s == 0) {
            return 0;
        }

        uint256 prevD;
        uint256 d = s;
        // uint256 nA = a.mul(numTokens);
        uint256 nA = a * numTokens;

        for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
            uint256 dP = d;
            for (uint256 j = 0; j < numTokens; j++) {
                dP = (dP * d) / (xp[j] * numTokens);
            }
            prevD = d;
            d = (((nA * s) / A_PRECISION) + (dP * numTokens)) * d
                / (((nA - A_PRECISION) * d / A_PRECISION) + ((numTokens + 1) * dP));

            // for (uint256 j = 0; j < numTokens; j++) {
            //     dP = dP.mul(d).div(xp[j].mul(numTokens));
            // }
            // prevD = d;
            // d = nA
            //     .mul(s)
            //     .div(A_PRECISION)
            //     .add(dP.mul(numTokens))
            //     .mul(d)
            //     .div(
            //         nA
            //             .sub(A_PRECISION)
            //             .mul(d)
            //             .div(A_PRECISION)
            //             .add((numTokens + 1).mul(dP))
            //     );
            // if (d.within1(prevD)) {
            //     return d;
            // }
            if (within(d, prevD)) {
                return d;
            }
        }

        revert("D does not converge");
    }

    function within(uint256 a, uint256 b) internal pure returns (bool) {
        return a + 1 >= b && a <= b + 1;
    }

    function getY(uint8 tokenIndexFrom, uint8 tokenIndexTo, uint256 x, uint256[2] memory xp, uint256 preciseA)
        internal
        pure
        returns (uint256)
    {
        uint256 numTokens = 2;
        require(tokenIndexFrom != tokenIndexTo, "Can't compare token to itself");
        require(tokenIndexFrom < numTokens && tokenIndexTo < numTokens, "Tokens must be in pool");

        uint256 d = getD(xp, preciseA);
        uint256 c = d;
        uint256 s;
        uint256 nA = numTokens * preciseA;

        uint256 _x;
        for (uint256 i = 0; i < numTokens; i++) {
            if (i == tokenIndexFrom) {
                _x = x;
            } else if (i != tokenIndexTo) {
                _x = xp[i];
            } else {
                continue;
            }
            s += _x;
            c = (c * d) / (_x * numTokens);
        }

        c = (c * d * A_PRECISION) / (nA * numTokens);
        uint256 b = s + (d * A_PRECISION) / nA;
        uint256 yPrev;
        uint256 y = d;

        for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
            yPrev = y;
            y = (y * y + c) / ((2 * y) + b - d);
            // if (y.within(yPrev)) {
            //     return y;
            // }
            if (within(y, yPrev, 1)) {
                return y;
            }
        }

        revert("Approximation did not converge");
    }

    function within(uint256 a, uint256 b, uint256 tolerance) internal pure returns (bool) {
        return a > b ? (a - b) <= tolerance : (b - a) <= tolerance;
    }

    // function getY(
    //     uint256 preciseA,
    //     uint8 tokenIndexFrom,
    //     uint8 tokenIndexTo,
    //     uint256 x,
    //     uint256[2] memory xp
    // ) internal pure returns (uint256) {
    //     uint256 numTokens = 2; // fixed size now
    //     require(tokenIndexFrom != tokenIndexTo, "Can't compare token to itself");
    //     require(tokenIndexFrom < numTokens && tokenIndexTo < numTokens, "Tokens must be in pool");

    //     uint256 d = getD(xp, preciseA);
    //     uint256 c = d;
    //     uint256 s;
    //     uint256 nA = numTokens.mul(preciseA);

    //     uint256 _x;
    //     for (uint256 i = 0; i < numTokens; i++) {
    //         if (i == tokenIndexFrom) {
    //             _x = x;
    //         } else if (i != tokenIndexTo) {
    //             _x = xp[i];
    //         } else {
    //             continue;
    //         }
    //         s = s.add(_x);
    //         c = c.mul(d).div(_x.mul(numTokens));
    //     }

    //     c = c.mul(d).mul(A_PRECISION).div(nA.mul(numTokens));
    //     uint256 b = s.add(d.mul(A_PRECISION).div(nA));
    //     uint256 yPrev;
    //     uint256 y = d;

    //     for (uint256 i = 0; i < MAX_LOOP_LIMIT; i++) {
    //         yPrev = y;
    //         y = y.mul(y).add(c).div(y.mul(2).add(b).sub(d));
    //         if (y.within1(yPrev)) {
    //             return y;
    //         }
    //     }

    //     revert("Approximation did not converge");
    // }

    // /// @notice Compute invariant D for given virtual balances xp and amplification coefficient amp
    // /// @param xp Array of virtual balances, length=2
    // /// @param amp Amplification coefficient (already scaled by A_PRECISION)
    // /// @return D The invariant
    // function getD(uint256[2] memory xp, uint256 amp) internal pure returns (uint256) {
    //     // sum of balances
    //     uint256 S = xp[0] + xp[1];
    //     if (S == 0) {
    //         return 0;
    //     }
    //     uint256 D = S;
    //     uint256 Ann = amp * N_COINS;
    //     // Newton iteration
    //     for (uint256 i = 0; i < 255; i++) {
    //         uint256 D_P = D;
    //         // D_P = D_P * D / (xp[k] * N_COINS) for each coin k
    //         D_P = (D_P * D) / (xp[0] * N_COINS);
    //         D_P = (D_P * D) / (xp[1] * N_COINS);

    //         uint256 Dprev = D;
    //         // D = (Ann * S / A_PRECISION + D_P * N_COINS) * D /
    //         //     ((Ann - A_PRECISION) * D / A_PRECISION + (N_COINS + 1) * D_P)
    //         uint256 num = (Ann * S / A_PRECISION + D_P * N_COINS) * D;
    //         uint256 den = ((Ann - A_PRECISION) * D / A_PRECISION) + (uint256(N_COINS) + 1) * D_P;
    //         D = num / den;

    //         // break when converged (precision of 1)
    //         if (D > Dprev) {
    //             if (D - Dprev <= 1) {
    //                 break;
    //             }
    //         } else {
    //             if (Dprev - D <= 1) {
    //                 break;
    //             }
    //         }
    //     }
    //     return D;
    // }

    // /// @notice Compute how much of coin j you get given an input to coin i, preserving invariant D
    // /// @param i Index of coin being deposited (0 or 1)
    // /// @param j Index of coin being withdrawn (0 or 1)
    // /// @param x New virtual balance of coin i after deposit
    // /// @param xp Original virtual balances (length=2)
    // /// @param amp Amplification coefficient (already scaled by A_PRECISION)
    // /// @return y New virtual balance of coin j after withdrawal
    // function getY(uint256 i, uint256 j, uint256 x, uint256[2] memory xp, uint256 amp) internal pure returns (uint256) {
    //     require(i != j, "StableSwapMath: same coin");

    //     // compute D invariant
    //     uint256 D = getD(xp, amp);
    //     uint256 Ann = amp * N_COINS;

    //     // compute c and b parameters
    //     uint256 c = D;
    //     uint256 S_ = 0;

    //     for (uint256 idx = 0; idx < N_COINS; idx++) {
    //         uint256 _x = (idx == i) ? x : xp[idx];
    //         if (idx == j) {
    //             continue;
    //         }
    //         S_ += _x;
    //         c = (c * D) / (_x * N_COINS);
    //     }
    //     // scale c by D / (Ann * N_COINS)
    //     c = (c * D) / (Ann * N_COINS);

    //     // b = S_ + D / Ann
    //     uint256 b = S_ + D / Ann;

    //     // newton iteration for y
    //     uint256 y = D;
    //     for (uint256 k = 0; k < 255; k++) {
    //         uint256 yPrev = y;
    //         // y = (y*y + c) / (2*y + b - D)
    //         y = (y * y + c) / ((y * 2) + b - D);

    //         // convergence check (precision of 1)
    //         if (y > yPrev) {
    //             if (y - yPrev <= 1) {
    //                 return y;
    //             }
    //         } else {
    //             if (yPrev - y <= 1) {
    //                 return y;
    //             }
    //         }
    //     }
    //     return y;
    // }
}
