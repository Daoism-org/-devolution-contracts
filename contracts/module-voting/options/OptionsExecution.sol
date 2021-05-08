// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "../../base-implementations/modules/BaseSubModule.sol";

// TODO logic for options execution
contract OptionsExecution is BaseSubModule {
    // Constant of this sub modules identifier
    bytes32 internal constant SubModuleIdentifier_ = "OptionsExecutor";

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(address _baseModule) 
        BaseSubModule(SubModuleIdentifier_, _baseModule)
    {
        
    }

    function init() external override {
        // TODO needs to get the address of the executor from the base
        // module which is turn getting it from the spoke dao.
    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS


    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS

    function registerOptionsOnModule() external override {

    }

    // -------------------------------------------------------------------------
    // ONLY EXECUTOR STATE MODIFYING FUNCTIONS

}