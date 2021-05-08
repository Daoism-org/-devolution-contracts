// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "../../system/base/BaseDao.sol";


abstract contract SpokeDao is BaseDao {

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(address _devolutionBase) BaseDao(_devolutionBase) {

    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS


    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS

    function registerSubModule() external virtual;
        // TODO on deployment of the submodule, the factory registers 

    function registerOptions() external virtual;
        // TODO allows a high level module to add the options of sub 
        // modules 

}