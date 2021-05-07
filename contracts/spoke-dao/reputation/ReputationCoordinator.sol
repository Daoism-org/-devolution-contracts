// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./IERC20.sol";

contract ReputationCoordinator {
    address internal base_; // TODO

    constructor(address _base) {
        base_ = _base;
    }

    

    function getVoterWeight(uint256 _voterID) external view returns(uint256) {
        
    }
}