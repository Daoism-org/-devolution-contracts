// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./IERC20.sol";
import "../base-implementations/modules/BaseModule.sol";
import "../base-implementations/spoke/BaseDaoLibrary.sol";

contract ReputationCoordinator is BaseModule {

    constructor(address _spokeDao) BaseModule(
        BaseDaoLibrary.ReputationCoordinator,
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

    function getVoterWeight(uint256 _voterID) external view returns(uint256) {
        
    }
}