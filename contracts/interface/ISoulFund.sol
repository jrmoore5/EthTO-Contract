// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface ISoulFund{
    struct Balances{
        address token;
        uint256 balance;
    }

    function balances(uint256 _tokenId) external view returns(Balances[] memory);
}
