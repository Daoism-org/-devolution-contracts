// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./VoteStorage.sol";
import "./VotingCoordinator.sol";
import "../module-reputation/IVoteWeight.sol";
import "../base-implementations/modules/BaseSubModule.sol";

contract VotingBooth is BaseSubModule {
    // Constant of this sub modules identifier
    bytes32 internal constant SubModuleIdentifier_ = "VotingBooth";
    // NOTES
    VotingCoordinator internal voteCoImp_; 
    // Needed information to count ballots for an election
    struct BallotCount {
        uint256 tally;
        uint256 weight;
        uint256 uniqueVoters;
    }
    // Needed information for each proposal election
    struct ProposalElection {
        uint256 expiry;
        BallotCount votesFor;
        BallotCount votesAgainst;
    }
    // Proposal ID => Proposal Election Information
    mapping(uint256 => ProposalElection) internal elections_;
    struct Voting {
        bool hasVoted;
        bool vote;
    }
    // Proposal ID => Voter (NFT ID) => Vote
    mapping(uint256 => mapping(uint256 => Voting)) internal voterRegistry_;

    // -------------------------------------------------------------------------
    // EVENTS

    event ProposalElectionRegistered(
        uint256 proposalID,
        uint256 expiryTimestamp
    );

    event BallotCast(
        uint256 proposalID,
        uint256 voterID,
        bool votePosition
    );

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(address _baseModule) 
        BaseSubModule(SubModuleIdentifier_, _baseModule)
    {
        voteCoImp_ = VotingCoordinator(_baseModule);
    }

    function init() external override {
        // module which is turn getting it from the spoke dao.
    }

    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS


    function registerOptionsOnModule() external override {

    }

    /**
     * @param   _propID The ID of the proposal election being registered.
     * @param   _expiryTimestamp Timestamp for the expiration of this election.
     * @notice  This function will revert if the given proposal ID has already
     *          been registered. 
     *          This function will revert if the given expiry time is zero or is
     *          in the past (before current time).
     */
    function registerElection(
        uint256 _propID,
        uint256 _expiryTimestamp
    ) 
        external 
        onlyModule(BaseDaoLibrary.ProposalRequester)
    {
        VoteStorage voteStorage = VoteStorage(
            baseModule_.getModuleFromBase(
                BaseDaoLibrary.VoteStorage
            )
        );

        uint256 currentExpiry = voteStorage.getProposalExpiry(_propID);

        require(
            currentExpiry == 0,
            "Prop ID already exists"
        );
        require(
            _expiryTimestamp != 0 && 
            _expiryTimestamp > block.timestamp,
            "Given expiry time invalid"
        );

        voteStorage.setElectionExpiry(_propID, _expiryTimestamp);

        emit ProposalElectionRegistered(
            _propID,
            _expiryTimestamp
        );
    }

    /**
     * @param   _voterID Unique ID of the voters NFT ID token.
     * @param   _propID ID of the prop that is being voted on.
     * @param   _vote The users vote for (true) or against (false) the 
     *          proposal. TODO M better name?
     * @notice  This function will revert if the proposal has expired, or if 
     *          the election for the proposal has not been registered. 
     *          TODO This function will revert if the `_voterID` is not a valid
     *          and registered ID on this DAO.
     *          This function will revert if the 
     */
    function castBinaryVote(
        uint256 _propID, 
        uint256 _voterID, 
        bool _vote
    ) external {
        require(
            isValidProposal(_propID),
            "prop expired or non-existant"
        );

        // Will revert if voter does not own Explorer token
        uint256 voteWeight = IVoteWeight(
            baseModule_.getModuleFromBase(
                BaseDaoLibrary.VotingWeight
            )
        ).getVoterWeight(msg.sender);

        VoteStorage(
            baseModule_.getModuleFromBase(
                BaseDaoLibrary.VoteStorage
            )
        ).castVote(_propID, _voterID, voteWeight, _vote);

        emit BallotCast(
            _propID,
            _voterID,
            _vote
        );
    }

    /**
     * @param   _propID The ID of the proposal being checked.
     * @return  bool If the proposal has been registered and is within voting
     *          period.
     */
    function isValidProposal(uint256 _propID) internal view returns(bool) {
        VoteStorage voteStorage = VoteStorage(
            baseModule_.getModuleFromBase(
                BaseDaoLibrary.VoteStorage
            )
        );
        
        uint256 currentExpiry = voteStorage.getProposalExpiry(_propID);

        if(currentExpiry == 0) {
            return false;
        } else if(voteStorage.isProposalInVoteWindow(_propID)) {
            return false;
        }
        return true;
    }
}