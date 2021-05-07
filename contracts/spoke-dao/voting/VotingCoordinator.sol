// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract VotingCoordinator {
    address internal base_; // TODO
    // Storage for valid state modifiers
    mapping(address => bool) internal stateModifiers_;

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(address _base) {
        base_ = _base;
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
        return stateModifiers_[_checked];
        // TODO should also have a check for executor address?
    }

    // TODO need to linking through spoke to other needed functionality
    // Coord needs to act as the middle man with interactions between these
    // external contracts and its child contracts
    
}