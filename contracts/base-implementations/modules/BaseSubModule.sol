// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./IBaseModule.sol";
import "../spoke/BaseDao.sol";
import "../spoke/BaseDaoLibrary.sol";
import "../../module-voting/options/IOptionsRegistry.sol";

abstract contract BaseSubModule {
    // Identifier for the submodule
    bytes32 public immutable SubModuleIdentifier;
    //
    IBaseModule internal baseModule_; 
    BaseDao internal baseDaoInstance_;

    // -------------------------------------------------------------------------
    // EVENTS

    event OptionRegistered(
        bytes32 optionID,
        bytes32 moduleIdentifier,
        address moduleImplementation,
        bytes4 functionSignature,
        string requiredData
    );

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

    modifier onlyModule(bytes32 _identifier) {
        require(
            msg.sender == baseModule_.getModuleFromBase(_identifier),
            "Only identified module"
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

    function getModuleFromBase(
        bytes32 _identifier
    ) external view returns(address) {
        return baseModule_.getModuleFromBase(_identifier);
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
    // function registerOptionsOnModule(
    //     bytes32 _moduleIdentifier,
    //     bytes4 _functionSignature,
    //     string calldata _requiredData
    // ) external virtual;
        // QS move modules to using new interface

    // -------------------------------------------------------------------------
    // INTERNAL FUNCTIONS

    function _registerOption(
       bytes32 _moduleIdentifier,
        bytes4 _functionSignature,
        string calldata _requiredData
    ) internal {
        IOptionsRegistry optionsReg = IOptionsRegistry(this.getModuleFromBase(
            BaseDaoLibrary.OptionsRegistry
        ));

        bytes32 optionID = optionsReg.registerOptionsOnModule(
            _moduleIdentifier,
            _functionSignature,
            _requiredData
        );

        emit OptionRegistered(
            optionID,
            _moduleIdentifier,
            address(this),
            _functionSignature,
            _requiredData
        );
    }
}