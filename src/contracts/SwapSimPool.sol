// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "./StableSwapMath.sol";
import "./MathUtils.sol";
import "./MockOracle.sol";

contract SwapSimPool {
    MockOracle public oracle;
    uint256 public amp; // raw A

    constructor(address _oracle, uint256 _initialA) {
        oracle = MockOracle(_oracle);
        amp = _initialA;
    }

    function setA(uint256 _A) external {
        amp = _A;
    }

    /// @notice Return virtual balances scaled by price
    function xp(uint256[2] memory rawBalances) public view returns (uint256[2] memory _xp) {
        uint256 p = oracle.getPrice(); // e.g. 1e18 == $1
        _xp[0] = rawBalances[0] * p / 1e18;
        _xp[1] = rawBalances[1] * 1e18 / p; // inverse-normalize
    }

    function getD(uint256[2] memory rawBalances) public view returns (uint256) {
        return StableSwapMath.getD(xp(rawBalances), amp);
    }

    function getY(uint256[2] memory rawBalances, uint256 dx) public view returns (uint256) {
        uint256[2] memory _xp0 = xp(rawBalances);
        uint256 x1 = _xp0[0] + dx * oracle.getPrice() / 1e18;
        return StableSwapMath.getY(0, 1, x1, _xp0, amp);
    }
}
