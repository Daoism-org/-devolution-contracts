// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

library BaseDaoLibrary {
    // Devolution Platform
    bytes32 public constant DevolutionDao = "DevolutionDao";
    bytes32 public constant DevolutionSystemIdentity = 
        "DevolutionSystemIdentity";
    
    // Spoke DAO 
    bytes32 public constant SpokeSpecificIdentity = 
        "SpokeSpecificIdentity";

    // Voting Module
    bytes32 public constant VotingCoordinator = "VotingCoordinator";
    bytes32 public constant OptionsExecutor = "OptionsExecutor";
    bytes32 public constant OptionsRegistry = 
        "OptionsRegistry";
}