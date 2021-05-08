// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "../spoke/BaseDaoLibrary.sol";
import "../spoke/BaseDao.sol";

contract BaseModule {
    // Identifier for the module
    bytes32 public immutable ModuleIdentifier;
    // Storage of the deployer for once off access
    address internal deployer_;
    // 
    BaseDao internal baseDaoInstance_;
    // If this Base DAO has been initialised
    bool internal alive_;
    // Information about modules
    struct SubModule {
        address implementation; 
        bool inUse;
    }
    // identifier of the module to its information
    mapping(bytes32 => SubModule) internal subModulesRegistry_;  
    
    // -------------------------------------------------------------------------
    // EVENTS

    event SubModuleRegistryUpdated(
        bytes32 identifier, 
        address oldModule, 
        address module,
        bool moduleInUse
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

    modifier isActive() {
        require(
            alive_,
            "Base DAO not initialised"
        );
        _;
    }

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(bytes32 _moduleIdentifier, address _spoke) {
        baseDaoInstance_ = BaseDao(_spoke);
        ModuleIdentifier = _moduleIdentifier;
    }

    function init(
        bytes32[] memory _subModulesIdentifiers,
        address[] memory _subModulesInstances
    ) external {
        require(
            !alive_,
            "Base has been initialised"
        );
        require(
            msg.sender == deployer_,
            "Only deployer can access"
        );
        require(
            _subModulesIdentifiers.length ==
            _subModulesIdentifiers.length,
            "Identifier and address mismatch"
        );
        // Removing the deployer rights
        deployer_ = address(0);
        // Setting up the needed addresses 
        for (uint256 i = 0; i < _subModulesIdentifiers.length; i++) {
            _registerSubModule(
                _subModulesIdentifiers[i],
                _subModulesInstances[i],
                true
            );
        }
        // Marking the module as initialised
        alive_ = true;
    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS

    function getModuleIdentifier() external view returns(bytes32) {
        return ModuleIdentifier;
    }

    function getSubModuleImplementationAndUse(
        bytes32 _identifier
    ) external view returns(address, bool) {
        return (
            subModulesRegistry_[_identifier].implementation,
            subModulesRegistry_[_identifier].inUse
        );
    }

    function getSubModuleAddress(bytes32 _identifier) external view returns(address) {
        return subModulesRegistry_[_identifier].implementation;
    }

    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS

    // -------------------------------------------------------------------------
    // ONLY EXECUTOR STATE MODIFYING FUNCTIONS

    function updateModule(
        bytes32 _identifier,
        address _newInstance,
        bool _useNewInstance
    ) external onlyExecutor() isActive() {
        ( 
            address currentImplementation,
            bool inUse
        ) = this.getSubModuleImplementationAndUse(_identifier);
        // Requiring the new instance to be different, OR requiring an update
        // of the in use status.
        require(
            _newInstance != currentImplementation || 
            _newInstance == currentImplementation && _useNewInstance != inUse,
            "New executor address invalid"
        );
        // Registering the module. 
        _registerSubModule(_identifier, _newInstance, _useNewInstance);
    }

    function killDao() external onlyExecutor() isActive() {
        alive_ = false;
    }

    // function registerOptions() external virtual;
        // TODO allows a high level module to add the options of sub 
        // modules 

    // -------------------------------------------------------------------------
    // INTERNAL FUNCTIONS

    /**
     * @param   _identifier of the implementation.
     * @param   _implementation address for the identifier.
     * @param   _use the implementation address or not (off switch).
     */
    function _registerSubModule(
        bytes32 _identifier,
        address _implementation,
        bool _use
    ) 
        private 
    {
        address currentImplementation = subModulesRegistry_[_identifier].implementation;

        subModulesRegistry_[_identifier] = SubModule({
            implementation: _implementation,
            inUse: _use
        });
        emit SubModuleRegistryUpdated(
            _identifier, 
            currentImplementation, 
            _implementation,
            _use
        );
    }
}