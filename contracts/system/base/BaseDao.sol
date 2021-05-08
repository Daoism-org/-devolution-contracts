// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./IDevBase.sol";
import "./BaseDaoLibrary.sol";

abstract contract BaseDao {
    // Storage for the devolution base DAO
    IDevBase internal devolutionBase_; 
    // Storage of the deployer for once off access
    address internal deployer_;
    // If this Base DAO has been initialised
    bool internal alive_;
    // Information about modules
    struct Module {
        address implementation; 
    }
    // identifier of the module to its information
    mapping(bytes32 => Module) internal modulesRegistry_;

    // -------------------------------------------------------------------------
    // EVENTS

    event ModuleRegistryUpdated(
        bytes32 identifier, 
        address oldModule, 
        address module
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
        devolutionBase_ = IDevBase(_devolutionBase);

        _registerModule(
            BaseDaoLibrary.DevolutionDao,
            _devolutionBase
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
     */
    function init(
        address _executorInstance,
        address _identityInstance,
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
        _registerModule(
            BaseDaoLibrary.OptionsExecutor,
            _executorInstance
        );
        _registerModule(
            BaseDaoLibrary.DevolutionSystemIdentity,
            _identityInstance
        );
        _registerModule(
            BaseDaoLibrary.SpokeSpecificIdentity,
            _spokeIdentityInstance
        );
        alive_ = true;
    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS

    function getModuleImplementation(bytes32 _identifier) external view returns(address) {
        return modulesRegistry_[_identifier].implementation;
    }

    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS

    // -------------------------------------------------------------------------
    // ONLY EXECUTOR STATE MODIFYING FUNCTIONS

    function updateModule(
        bytes32 _identifier,
        address _newInstance
    ) external onlyExecutor() isActive() {
        address currentImplementation = this.getModuleImplementation(_identifier);

        require(
            _newInstance != currentImplementation,
            "New executor address invalid"
        );

        _registerModule(_identifier, _newInstance);
    }

    function killDao() external onlyExecutor() isActive() {
        alive_ = false;
    }
    
    // -------------------------------------------------------------------------
    // INTERNAL FUNCTIONS

    function _registerModule(
        bytes32 _identifier,
        address _implementation
    ) 
        internal 
        isActive() 
    {
        address currentImplementation = modulesRegistry_[_identifier].implementation;

        modulesRegistry_[_identifier] = Module({
            implementation: _implementation
        });
        emit ModuleRegistryUpdated(
            _identifier, 
            currentImplementation, 
            _implementation
        );
    }

    function _registerOptions() internal {
        
    }
}