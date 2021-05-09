/* External Imports */
const { ethers, network } = require('hardhat')
const chai = require('chai')
const { solidity } = require('ethereum-waffle')
const chaiAsPromised = require('chai-as-promised')
const { expect } = chai

chai.use(chaiAsPromised)
chai.use(solidity)

describe("Basic Deployment Test", () =>  {
    // Contracts

    // Devolution platform contracts
    let DevBaseInstance;

    let DevIDInstance;
    
    // Spoke DAO contracts
    let SpokeDaoInstance;
    
    // Voting Module
    let VotingModuleContract;
    let VoteStorageContract;
    let VoteBoothContract;
    let GeneralCensusContract;
    // Voting module instances
    let VotingModuleInstance;
    let VoteStorageInstance;
    let VoteBoothInstance;
    let GeneralCensusInstance;
    
    // Reputation Module
    let ReputationModuleContract;
    let VotingWeightContract;
    let ReputationTokenContract;
    let ReputationDistributionContract;
    // Reputation module instances
    let ReputationModuleInstance;
    let VotingWeightInstance;
    let ReputationTokenInstance;
    let ReputationDistributionInstance;

    // Signers
    let deployer;
    let spokeCreator;
    let spokeParticipant;
    let voterFor;
    let voterAgainst;

    before(async () => {
        // Getting all the contracts 

        // Devolution platform
        const DevBaseContract = await ethers.getContractFactory("DevolutionBase");
        const DevIDContract = await ethers.getContractFactory("ExplorerID");

        // Spoke DAO contracts
        const SpokeDaoContract = await ethers.getContractFactory("SpokeDao");

        VotingModuleContract = await ethers.getContractFactory("VotingCoordinator");
        VoteStorageContract = await ethers.getContractFactory("VoteStorage");
        VoteBoothContract = await ethers.getContractFactory("VotingBooth");
        GeneralCensusContract = await ethers.getContractFactory("GeneralCensus");
        
        ReputationModuleContract = await ethers.getContractFactory("ReputationCoordinator");
        VotingWeightContract = await ethers.getContractFactory("VotingWeight");
        ReputationTokenContract = await ethers.getContractFactory("ReputationToken");
        ReputationDistributionContract = await ethers.getContractFactory("ReputationDistribution");

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
        console.log("Devolution Base Deployed...");

        DevIDInstance = await DevIDContract.deploy(
            DevBaseInstance.address
        );
        console.log("Devolution Identity Deployed...");
        
        await (await DevBaseInstance.addIdentityInstance(
            DevIDInstance.address
        )).wait();
        console.log("Devolution Identity Successfully registered");
        
        SpokeDaoInstance = await SpokeDaoContract.deploy(
            DevBaseInstance.address
        );
        console.log("Spoke DAO Deployed...");

        // ---------------------------------------------------------------------
        // Voting Module

        VotingModuleInstance = await VotingModuleContract.deploy(
            SpokeDaoInstance.address
        );

        VoteStorageInstance = await VoteStorageContract.deploy(
            VotingModuleInstance.address
        );

        VoteBoothInstance = await VoteBoothContract.deploy(
            VotingModuleInstance.address
        );

        GeneralCensusInstance = await GeneralCensusContract.deploy(
            VotingModuleInstance.address,
            1,
            1
        );

        console.log("Deployed Vote Module and submodules...");

        await VotingModuleInstance.registerSubmodule(
            VoteStorageInstance.address
        );

        await VotingModuleInstance.registerSubmodule(
            VoteBoothInstance.address
        );

        await VotingModuleInstance.registerSubmodule(
            GeneralCensusInstance.address
        );

        console.log("Successfully registered submodules");

        // ---------------------------------------------------------------------
        // Reputation Module

        ReputationModuleInstance = await ReputationModuleContract.deploy(
            SpokeDaoInstance.address
        );

        VotingWeightInstance = await VotingWeightContract.deploy(
            VotingModuleInstance.address
        );

        ReputationTokenInstance = await ReputationTokenContract.deploy(
            VotingModuleInstance.address
        );

        ReputationDistributionInstance = await ReputationDistributionContract.deploy(
            VotingModuleInstance.address
        );

        console.log("Deployed Reputation Module and submodules...");

        await ReputationModuleInstance.registerSubmodule(
            VotingWeightInstance.address
        );

        await ReputationModuleInstance.registerSubmodule(
            ReputationTokenInstance.address
        );

        await ReputationModuleInstance.registerSubmodule(
            ReputationDistributionInstance.address
        );

        console.log("Successfully registered submodules");

        // ---------------------------------------------------------------------
        // Registering modules on Spoke DAO

        let tx = await (
            await SpokeDaoInstance.init(
                VotingModuleInstance.address,
                ReputationModuleInstance.address
            )
        ).wait();
    });

    describe("Checks state changes as expected", () => { 
        it("Can get modules from Spoke DAO", async () => {
            let identifier = await GeneralCensusInstance.getModuleIdentifier();

            let test = await SpokeDaoInstance.getModuleAddress(identifier)

            console.log(test)
            console.log(GeneralCensusInstance.address)
        });
    });
});