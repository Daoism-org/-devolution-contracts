// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;


abstract contract BaseSubModule {
    address internal baseModule_; // TODO interface

    constructor(address _baseModule) {
        baseModule_ = _baseModule;
    }

    function subModuleRegistry() external virtual returns(address);
        // TODO on deployment of the submodule, the factory registers 

    function registerOptionsOnModule() external virtual;
        // TODO allows a high level module to add the options of sub 
        // modules 
        // May need to do it per sub module if the gas restrictions 
        // get too high.

}