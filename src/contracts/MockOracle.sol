// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

contract MockOracle {
    uint256 private price;

    function setPrice(uint256 p) external {
        price = p;
    }

    function getPrice() external view returns (uint256) {
        return price;
    }
}
