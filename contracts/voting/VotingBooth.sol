// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract VotingBooth {
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

    event BallotCast(
        uint256 proposalID,
        uint256 voterID,
        bool votePosition
    );

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor() {

    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS

    /**
     * @param   _propID The ID of the proposal election being checked.
     * @return  tallyVotesFor The total votes for.
     * @return  tallyWeightFor The weight of all votes for.
     * @return  tallyVotersFor The number of unique voters for.
     * @return  tallyVotesAgainst The total votes against.
     * @return  tallyWeightAgainst The weight of all votes against.
     * @return  tallyVotersAgainst The number of unique voters against.
     */
    function getProposalElectionResults(
        uint256 _propID
    ) 
        external 
        view 
        returns(
            uint256 tallyVotesFor,
            uint256 tallyWeightFor,
            uint256 tallyVotersFor,
            uint256 tallyVotesAgainst,
            uint256 tallyWeightAgainst,
            uint256 tallyVotersAgainst
        ) 
    {
        // For
        tallyVotesFor = elections_[_propID].votesFor.tally;
        tallyWeightFor = elections_[_propID].votesFor.weight;
        tallyVotersFor = elections_[_propID].votesFor.uniqueVoters;
        // Against
        tallyVotesAgainst = elections_[_propID].votesAgainst.tally;
        tallyWeightAgainst = elections_[_propID].votesAgainst.weight;
        tallyVotersAgainst = elections_[_propID].votesAgainst.uniqueVoters;
    }

    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS

    /**
     * @param   _propID The ID of the proposal election being registered.
     * @param   _expiryTimeStamp Timestamp for the expiration of this election.
     * @notice  This function will revert if the given proposal ID has already
     *          been registered. 
     *          This function will revert if the given expiry time is zero or is
     *          in the past (before current time).
     */
    function registerElection(
        uint256 _propID,
        uint256 _expiryTimeStamp
    ) 
        external 
    {
        require(
            elections_[_propID].expiry == 0,
            "Prop ID already exists"
        );
        require(
            _expiryTimeStamp != 0 && 
            _expiryTimeStamp > block.timestamp,
            "Given expiry time invalid"
        );
        elections_[_propID].expiry = _expiryTimeStamp;
    }

    /**
     * @param   _voterID Unique ID of the voters NFT ID token.
     * @param   _propID ID of the prop that is being voted on.
     * @param   _isFor The users vote for (true) or against (false) the 
     *          proposal. TODO M better name?
     * @notice  This function will revert if the proposal has expired, or if 
     *          the election for the proposal has not been registered. 
     *          TODO This function will revert if the `_voterID` is not a valid
     *          and registered ID on this DAO.
     */
    function castBinaryVote(
        uint256 _propID, 
        uint256 _voterID, 
        bool _isFor
    ) external {
        require(
            isValidProposal(_propID),
            "prop expired or non-existant"
        );

        // TODO check if proposal passes with current status

        // Storing the users vote
        voterRegistry_[_propID][_voterID].vote = _isFor;
        if(_isFor) {
            elections_[_propID].votesFor.tally += 1;
            elections_[_propID].votesFor.uniqueVoters += 1;
            // If the user has voted before their vote weight will not update
            if(!voterRegistry_[_propID][_voterID].hasVoted) {
                // TODO vote weight
                // repCoord.getUserVoteWeight(_voterID) 
                // Can revert if NFT does not exist on DAO
                voterRegistry_[_propID][_voterID].hasVoted = true;
            }
        } else {
            elections_[_propID].votesAgainst.tally += 1;
            elections_[_propID].votesAgainst.uniqueVoters += 1;
            // If the user has voted before their vote weight will not update
            if(!voterRegistry_[_propID][_voterID].hasVoted) {
                // TODO vote weight
                voterRegistry_[_propID][_voterID].hasVoted = true;
            }
        }

        emit BallotCast(
            _propID,
            _voterID,
            _isFor
        );
    }

    function isValidProposal(uint256 _propID) internal returns(bool) {
        if(elections_[_propID].expiry == 0) {
            return false;
        } else if(elections_[_propID].expiry < block.timestamp) {
            return false;
        }
        return true;
    }
}