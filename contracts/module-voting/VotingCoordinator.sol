// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "../base-implementations/modules/BaseModule.sol";
import "../base-implementations/spoke/BaseDaoLibrary.sol";

contract VotingCoordinator is BaseModule {

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(address _spokeDao) BaseModule(
        BaseDaoLibrary.VotingCoordinator,
        _spokeDao
    ) {
    }

    function init(
        bytes32[] memory _subModulesIdentifiers,
        address[] memory _subModulesInstances
    ) external override {
        _init(
            _subModulesIdentifiers,
            _subModulesInstances
        );
    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS

    /**
     * @return  address The address of the current storage implementation.
     */
    function getStorage() external view returns(address) {
        return address(0);
    }

    /**
     * @param   _checked The address being checked
     * @return  bool If the `_checked` address is registered as a valid state
     *          modifier.
     */
    function isValidStateModifier(
        address _checked
    ) 
        external 
        view 
        returns(bool) 
    {
        return subModulesRegistry_[
            subModuleLookup_[_checked]
        ].inUse;
        // TODO should also have a check for executor address?
    }

    // TODO need to linking through spoke to other needed functionality
    // Coord needs to act as the middle man with interactions between these
    // external contracts and its child contracts
    
}