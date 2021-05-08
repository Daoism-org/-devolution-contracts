// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;


abstract contract BaseModule {
    bytes32 public immutable ModuleIdentifier;

    constructor(bytes32 _identifier, address _spoke) {
        // base_ = _base;
        ModuleIdentifier = _identifier;
    }

    function registerSubModule() external virtual;
        // TODO on deployment of the submodule, the factory registers 

    function registerOptions() external virtual;
        // TODO allows a high level module to add the options of sub 
        // modules 

}