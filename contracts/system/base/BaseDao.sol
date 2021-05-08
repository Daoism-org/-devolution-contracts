// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./IDevBase.sol";

abstract contract BaseModule {
    // Storage for the devolution base DAO
    IDevBase internal devolutionBase_; 
    // Storage of the deployer for once off access
    address internal deployer_;
    //
    address internal executor_;
    //
    struct Module {
        address implementation;
    }
    // address of the module to its information
    mapping(address => Module) internal modulesRegistry_;

    // -------------------------------------------------------------------------
    // EVENTS

    event ModuleRegistered(address module);

    // -------------------------------------------------------------------------
    // MODIFIERS

    modifier onlyExecutor() {
        require(
            msg.sender == executor_,
            "Only executor may call"
        );
        _;
    }

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(address _devolutionBase) {
        devolutionBase_ = _devolutionBase;
        deployer_ = msg.sender;
    }

    function init(
        address _executorInstance
    ) external {
        require(
            msg.sender == deployer_,
            "Only deployer can access"
        );
        // Removing the deployer rights
        deployer_ = address(0);
        // Setting up the needed addresses 
        executor_ = _executorInstance;
    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS



    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS



    // -------------------------------------------------------------------------
    // ONLY EXECUTOR STATE MODIFYING FUNCTIONS

    function updateExecutorAddress(
        address _newExecutor
    ) external onlyExecutor() {
        require(
            _newExecutor != address(0) && _newExecutor != executor_,
            "New executor address invalid"
        );
    }
    
    // -------------------------------------------------------------------------
    // INTERNAL FUNCTIONS

    function _registerModule(
        address _module
    ) internal {
        modulesRegistry_[_module] = Module({
            implementation: _module
        });
        emit ModuleRegistered(_module);
    }

    function _registerOptions() internal {

    }
}