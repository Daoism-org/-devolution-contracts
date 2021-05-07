// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;


abstract contract BaseModule {
    address internal base_; // TODO

    constructor(address _base) {
        base_ = _base;
    }

    function registerSubModule() external virtual;
        // TODO on deployment of the submodule, the factory registers 

    function registerOptions() external virtual;
        // TODO allows a high level module to add the options of sub 
        // modules 

}