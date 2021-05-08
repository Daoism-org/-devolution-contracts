// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

interface IBaseModule {

    function getModuleIdentifier() external view returns(bytes32);

}