const chai = require('chai')
const { ethers } = require("hardhat");

describe("Basic Deployment Test", () =>  {
    // Contracts

    // Devolution platform contracts
    let DevBaseContract;
    let DevBaseInstance;

    let DevIDContract;
    let DevIDInstance;
    
    // Spoke DAO contracts
    let SpokeDaoContract;
    let SpokeDaoInstance;
    
    let VotingModuleContract;
    let VotingModuleInstance;
    
    let ReputationModuleContract;
    let ReputationModuleInstance;

    // Signers
    let deployer;
    let spokeCreator;
    let spokeParticipant;
    let voterFor;
    let voterAgainst;

    beforeEach(async () => {
        // Getting all the contracts 

        // Devolution platform
        DevBaseContract = await ethers.getContractFactory("DevolutionBase");
        DevIDContract = await ethers.getContractFactory("ExplorerID");

        // Spoke DAO contracts
        SpokeDaoContract = await ethers.getContractFactory("SpokeDao");

        // VotingModuleContract = await ethers.getContractFactory("NFT");
        // ReputationModuleContract = await ethers.getContractFactory("NFT");

        // Getting signers
        [
            deployer, 
            spokeCreator, 
            spokeParticipant, 
            voterFor,
            voterAgainst
        ] = await ethers.getSigners();

        // Deploying contracts
        DevBaseInstance = await DevBaseContract.deploy();
        DevIDInstance = await DevIDContract.deploy();

        await DevBaseInstance.addIdentityInstance(DevIDInstance.address);
        
        SpokeDaoInstance = await SpokeDaoContract.deploy(
            DevBaseInstance.address
        );
        // VotingModuleInstance = await VotingModuleContract.deploy();

    });

    describe("Creating Lot Tests", () => { 
        it("Creating a lot with event", async () => {
            console.log("here");
        });
    });
});