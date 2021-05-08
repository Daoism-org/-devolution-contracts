// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./BaseDaoLibrary.sol";
import "../modules/IBaseModule.sol";

/**
 * @author
 * @notice  
 */
abstract contract BaseDao {
    // Identifier for the module
    bytes32 public immutable ModuleIdentifier;
     // Constant of this sub modules identifier
    bytes32 internal constant DaoIdentifier_ = "SpokeDaoV_0.1";
    // Storage for the devolution base DAO
    address internal devolutionBase_; // FUTURE fif needed make interface
    // Storage of the deployer for once off access
    address internal deployer_;
    // If this Base DAO has been initialised
    bool internal alive_;
    // Information about modules
    struct Module {
        address implementation; 
        bool inUse;
        bool isSubModule;
    }
    // identifier of the module to its information
    mapping(bytes32 => Module) internal allSpokeModules_;

    // -------------------------------------------------------------------------
    // EVENTS

    event ModuleRegistryUpdated(
        bytes32 identifier, 
        address oldModule, 
        address module,
        bool moduleInUse
    );

    // -------------------------------------------------------------------------
    // MODIFIERS

    modifier onlyExecutor() {
        require(
            msg.sender == allSpokeModules_[
                BaseDaoLibrary.OptionsExecutor
            ].implementation,
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

    constructor(address _devolutionBase) {
        devolutionBase_ = _devolutionBase;
        ModuleIdentifier = DaoIdentifier_;

        _registerModule(
            BaseDaoLibrary.DevolutionDao,
            _devolutionBase,
            true
        );

        deployer_ = msg.sender;
    }

    /**
     * @param   _executorInstance Contract instance of the options execution. 
     *          This is needed in order to protect option execution logic.
     * @param   _identityInstance Contract instance of the system wide identity
     *          solution. This contract is needed for identifying users through-
     *          out the system. This identity is implemented as a unique uint256
     *          identifier attached to a user in the form of an NFT.
     * @param   _spokeIdentityInstance Contract instance for the OPTIONAL spoke
     *          DAO specific identity NFT token.
     * @notice  This function will revert if the msg.sender is not the deploying
     *          address.
     */
    function init(
        address _executorInstance,
        address _identityInstance,
        address _optionsRegistryInstance,
        address _spokeIdentityInstance
    ) external {
        require(
            !alive_,
            "Base has been initialised"
        );
        require(
            msg.sender == deployer_,
            "Only deployer can access"
        );
        // Removing the deployer rights
        deployer_ = address(0);
        // Setting up the needed addresses 
        // TODO need to change to registering the voting & rep coord
        // TODO then from those get the addresses of these submodules below
        _registerModule(
            BaseDaoLibrary.OptionsExecutor,
            _executorInstance,
            true
        );
        _registerModule(
            BaseDaoLibrary.DevolutionSystemIdentity,
            _identityInstance,
            true
        );
        _registerModule(
            BaseDaoLibrary.OptionsRegistry,
            _optionsRegistryInstance,
            true
        );
        _registerModule(
            BaseDaoLibrary.SpokeSpecificIdentity,
            _spokeIdentityInstance,
            true
        );
        // Marking the base DAO as initialised
        alive_ = true;
    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS

    function getModuleImplementationAndUse(
        bytes32 _identifier
    ) external view returns(address, bool) {
        return (
            allSpokeModules_[_identifier].implementation,
            allSpokeModules_[_identifier].inUse
        );
    }

    function getModuleAddress(bytes32 _identifier) external view returns(address) {
        return allSpokeModules_[_identifier].implementation;
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
        ) = this.getModuleImplementationAndUse(_identifier);
        // Requiring the new instance to be different, OR requiring an update
        // of the in use status.
        require(
            _newInstance != currentImplementation || 
            _newInstance == currentImplementation && _useNewInstance != inUse,
            "New executor address invalid"
        );
        // Registering the module. 
        _registerModule(_identifier, _newInstance, _useNewInstance);
    }

    // TODO registering options

    function killDao() external onlyExecutor() isActive() {
        alive_ = false;
    }
    
    // -------------------------------------------------------------------------
    // INTERNAL FUNCTIONS

    /**
     * @param   _identifier of the implementation.
     * @param   _implementation address for the identifier.
     * @param   _use the implementation address or not (off switch).
     */
    function _registerModule(
        bytes32 _identifier,
        address _implementation,
        bool _use
    ) 
        internal 
    {
        IBaseModule module = IBaseModule(_implementation);
        require(
            module.getModuleIdentifier() == _identifier,
            "Implementation ID mismatch"
        );

        address currentImplementation = allSpokeModules_[_identifier].implementation;

        allSpokeModules_[_identifier] = Module({
            implementation: _implementation,
            inUse: _use,
            isSubModule: false
        });

        emit ModuleRegistryUpdated(
            _identifier, 
            currentImplementation, 
            _implementation,
            _use
        );

        _registerSubModules(module, module.getAllSubModules());
    }

    function _registerSubModules(
        IBaseModule _module, 
        bytes32[] memory _identifiers
    ) 
        internal 
        returns(bool) 
    {
        if(_identifiers.length == 0) {
            return false;
        }
        for (uint256 i = 0; i < _identifiers.length; i++) {
            // Getting the implementation address and use status
            (
                address implementation,
                bool isInUse
            ) = _module.getSubModuleImplementationAndUse(
                _identifiers[i]
            );
            // Storing the submodule information
            allSpokeModules_[_identifiers[i]] = Module({
                implementation: implementation,
                inUse: isInUse,
                isSubModule: true
            });

            emit ModuleRegistryUpdated(
                _identifiers[i], 
                address(0),         // FUTURE should not be hardcoded
                implementation,
                isInUse
            );
        }
        return true;
    }

    function _registerOptions() internal {
        // TODO Make the options registry 
    }
}