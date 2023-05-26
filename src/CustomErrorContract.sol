// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract CustomErrorContract {
    error SomeError(uint256);

    function revertError(uint256 x) public pure {
        revert SomeError(x);
    }
}
