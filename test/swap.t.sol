// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/contracts/SwapSimPool.sol";
import "../src/contracts/MockOracle.sol";
import "forge-std/console.sol";

contract Swap is Test {
    MockOracle oracle;
    SwapSimPool pool;

    uint256 constant INITIAL_BALANCE = 10_000e18;

    uint256[] As = [uint256(100), 500, 2000];
    uint256[] prices = [0.9e18, 1e18, 1.1e18];
    uint256[] dxs = [0.01e18, 0.1e18, 0.5e18, 1e18, 5e18, 10e18];

    function setUp() public {
        oracle = new MockOracle();
        pool = new SwapSimPool(address(oracle), /*A=*/ 100);
    }

    function testCurvePoints() public {
        console.logString("dx,price,A,D,xp0,xp1,y"); // CSV header
        uint256[2] memory balances = [uint256(10e18), uint256(10e18)];

        for (uint256 i = 0; i < As.length; i++) {
            pool.setA(As[i]);
            for (uint256 j = 0; j < prices.length; j++) {
                oracle.setPrice(prices[j]);
                uint256 D = pool.getD(balances);
                for (uint256 k = 0; k < dxs.length; k++) {
                    uint256 dx = dxs[k];
                    uint256[2] memory xp0 = pool.xp(balances);
                    // uint256 x1 = xp0[0] + (dx * prices[j] / 1e18);
                    uint256 y = pool.getY(balances, dx);

                    string memory line = string.concat(
                        vm.toString(dx),
                        ",",
                        vm.toString(prices[j]),
                        ",",
                        vm.toString(As[i]),
                        ",",
                        vm.toString(D),
                        ",",
                        vm.toString(xp0[0]),
                        ",",
                        vm.toString(xp0[1]),
                        ",",
                        vm.toString(y)
                    );
                    console.logString(line);
                }
            }
        }
    }



    function testBasicSwap() public {
        uint256[2] memory balances = [INITIAL_BALANCE, INITIAL_BALANCE];

        oracle.setPrice(1e18);

        //  balanced pools
        uint256 dx = 100e18;
        uint256 newY = pool.getY(balances, dx);
        uint256 dy = balances[1] - newY;

        //  a tiny bit of slippage @1%
        assertApproxEqRel(dy, dx, 0.01e18); //

        // Increase trade size, == more slippage
        dx = 1000e18;
        newY = pool.getY(balances, dx);
        dy = balances[1] - newY;

        assertLt(dy, dx);
        //slippage with A=100
        assertGt(dy, dx * 95 / 100);
    }



}
