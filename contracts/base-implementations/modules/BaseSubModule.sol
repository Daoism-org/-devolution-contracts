// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./IBaseModule.sol";
import "../spoke/BaseDao.sol";

abstract contract BaseSubModule {
    // Identifier for the submodule
    bytes32 public immutable SubModuleIdentifier;
    //
    IBaseModule internal baseModule_; 
    BaseDao internal baseDaoInstance_;


    // -------------------------------------------------------------------------
    // MODIFIERS

    modifier onlyExecutor() {
        require(
            msg.sender == baseDaoInstance_.getModuleAddress(
                BaseDaoLibrary.OptionsExecutor
            ),
            "Only executor may call"
        );
        _;
    }

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(bytes32 _identifier, address _baseModule) {
        baseModule_ = IBaseModule(_baseModule);
        baseDaoInstance_ = BaseDao(baseModule_.getBaseDao());

        SubModuleIdentifier = _identifier;
    }

    function init() external virtual;

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS

    function getModuleIdentifier() external view returns(bytes32) {
        return SubModuleIdentifier;
    }

    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS

    // function registerOptions(
    //     bytes4 _functionSig,
    //     bytes _parameters
    //     // TODO options registry 
    // )

    // -------------------------------------------------------------------------
    // ONLY EXECUTOR STATE MODIFYING FUNCTIONS

    function registerOptionsOnModule() external virtual;
        // TODO allows a high level module to add the options of sub 
        // modules 
        // May need to do it per sub module if the gas restrictions 
        // get too high.

}