// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./BaseDaoLibrary.sol";
import "../modules/IBaseModule.sol";

abstract contract BaseDao {
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
    }
    // identifier of the module to its information
    mapping(bytes32 => Module) internal modulesRegistry_;

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
            msg.sender == modulesRegistry_[
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
            modulesRegistry_[_identifier].implementation,
            modulesRegistry_[_identifier].inUse
        );
    }

    function getModuleAddress(bytes32 _identifier) external view returns(address) {
        return modulesRegistry_[_identifier].implementation;
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
        private 
    {
        require(
            IBaseModule(_implementation).getModuleIdentifier() == _identifier,
            "Implementation ID mismatch"
        );

        address currentImplementation = modulesRegistry_[_identifier].implementation;

        modulesRegistry_[_identifier] = Module({
            implementation: _implementation,
            inUse: _use
        });
        emit ModuleRegistryUpdated(
            _identifier, 
            currentImplementation, 
            _implementation,
            _use
        );
    }

    function _registerOptions() internal {
        // TODO Make the options registry 
    }
}