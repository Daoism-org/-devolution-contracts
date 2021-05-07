// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;


abstract contract BaseSubModule {
    address internal base_; // TODO

    constructor(address _base) {
        base_ = _base;
    }

    function subModuleRegistry() external virtual returns(address);
        // TODO on deployment of the submodule, the factory registers 

    function registerOptionsOnModule() external virtual;
        // TODO allows a high level module to add the options of sub 
        // modules 

}