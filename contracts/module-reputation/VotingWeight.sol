// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract VotingWeight {
    address internal base_; // FIXME remove into base sub module

    constructor(address _base) {
        base_ = _base;
    }
}