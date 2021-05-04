// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract VotingCoordinator {
    constructor() {}

    function getStorage() external view returns(address) {
        return address(0);
    }
    function isValidStateModifier(address _checked) external view returns(bool) {
        return true;
    }
}