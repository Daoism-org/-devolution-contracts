// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract VotingCoordinator {
    // Storage for valid state modifiers
    mapping(address => bool) internal stateModifiers_;

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor() {}

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
}