// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract OptionsRegistry {
    address internal base_; // TODO remove into base sub module

    constructor(address _base) {
        base_ = _base;
    }
}