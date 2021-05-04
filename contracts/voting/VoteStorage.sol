// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./VotingCoordinator.sol";

contract VoteStorage {
    VotingCoordinator internal voteCoImp_; 
    // Needed information to count ballots for an election
    struct BallotCount {
        uint256 tally;
        uint256 weight;
    }
    // Needed information for each proposal election
    struct ProposalElection {
        uint256 expiry;
        BallotCount votesFor;
        BallotCount votesAgainst;
        bool consensusReached;
        bool motionPassed;
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
    // MODIFIERS

    modifier onlyApprovedModifiers() {
        require(
            voteCoImp_.isValidStateModifier(msg.sender),
            "Sender not valid state modifier"
        );
        _;
    }

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(address _voteCo) {
        voteCoImp_ = VotingCoordinator(_voteCo);
    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS

        /**
     * @param   _propID The ID of the proposal election being checked.
     * @return  tallyVotesFor The total votes for.
     * @return  tallyWeightFor The weight of all votes for.
     * @return  tallyVotesAgainst The total votes against.
     * @return  tallyWeightAgainst The weight of all votes against.
     */
    function getProposalElectionResults(
        uint256 _propID
    ) 
        external 
        view 
        returns(
            uint256 tallyVotesFor,
            uint256 tallyWeightFor,
            uint256 tallyVotesAgainst,
            uint256 tallyWeightAgainst
        ) 
    {
        // For
        tallyVotesFor = elections_[_propID].votesFor.tally;
        tallyWeightFor = elections_[_propID].votesFor.weight;
        // Against
        tallyVotesAgainst = elections_[_propID].votesAgainst.tally;
        tallyWeightAgainst = elections_[_propID].votesAgainst.weight;
    }

    /**
     * @param   _propID The ID of the proposal election being checked.
     * @return  uint256 Expiry time stamp of the proposal
     */
    function getProposalExpiry(uint256 _propID) external view returns(uint256) {
        return elections_[_propID].expiry;
    }

    /**
     * @param   _propID The ID of the proposal election being checked.
     * @return  uint256 Expiry time stamp of the proposal
     */
    function isProposalInVoteWindow(
        uint256 _propID
    ) 
        external 
        view 
        returns(bool) 
    {
        if(elections_[_propID].expiry < block.timestamp) {
            return false;
        }
        return true;
    }

    /**
     * @param   _propID The ID of the proposal election being checked.
     * @return  totalVotes Total votes cast (so far) for this election.
     * @return  totalWeight Total weight voted with (so far) for this election.
     */
    function getProposalElectionTotals(
        uint256 _propID
    ) 
        external 
        view 
        returns(
            uint256 totalVotes,
            uint256 totalWeight
        )
    {
        totalVotes = elections_[_propID].votesFor.tally + 
            elections_[_propID].votesAgainst.tally;
        totalWeight = elections_[_propID].votesFor.weight +
            elections_[_propID].votesAgainst.weight;
    }

    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS

    function setElectionExpiry(
        uint256 _propID,
        uint256 _expiry
    ) 
        external
        onlyApprovedModifiers()
    {
        elections_[_propID].expiry = _expiry;
    }

    function castVote(
        uint256 _propID,
        uint256 _voterID,
        uint256 _voteWeight,
        bool _vote 
    ) 
        external
        onlyApprovedModifiers()
    {
        require(
            voterRegistry_[_propID][_voterID].hasVoted == false,
            "Vote already cast"
        );
        // Storing the users vote
        voterRegistry_[_propID][_voterID].vote = _vote;
        if(_vote) {
            elections_[_propID].votesFor.tally += 1;
            elections_[_propID].votesFor.weight += _voteWeight;
        } else {
            elections_[_propID].votesAgainst.tally += 1;
            elections_[_propID].votesAgainst.weight += _voteWeight;
        }
        voterRegistry_[_propID][_voterID].hasVoted = true;
    }
}