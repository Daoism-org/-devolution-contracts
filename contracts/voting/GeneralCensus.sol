// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./VotingCoordinator.sol";
import "./VoteStorage.sol";

contract GeneralCensus {
    VotingCoordinator internal voteCoImp_; 
    VoteStorage internal storageImp_;
    // TODO interface
    address internal voterCo_;
    // Consensus parameters
    // The minimum number of votes cast for a vote to reach consensus
    uint256 public minimumVotes;
    // The minimum amount of weight behind votes for a vote to reach consensus
    uint256 public minimumWeight;

    // -------------------------------------------------------------------------
    // CONSTRUCTOR

    constructor(
        address _voterCo,
        uint256 _minVotes,
        uint256 _minWeight
    ) {
        voteCoImp_ = VotingCoordinator(_voterCo);
        _isCurrent();
        minimumVotes = _minVotes;
        minimumWeight = _minWeight;
    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS

    function doesElectionReachConsensus(
        uint256 _propID
    ) 
        external
        view
        returns(
            bool consensusReached,
            bool isPassed
        ) 
    {
        // Checks the minimum engagement requirements are met
        if(!_minEngagementReached(_propID)) {
            return (false, false);
        }
        // Getting information for consensus
        (
            uint256 tallyVotesFor,
            uint256 tallyWeightFor,
            uint256 tallyVotesAgainst,
            uint256 tallyWeightAgainst
        ) = storageImp_.getProposalElectionResults(_propID);
        (
            bool votesReached, 
            bool voteIsFor
        ) = _simpleMajority(tallyVotesFor, tallyVotesAgainst);
        (
            bool weightReached, 
            bool weightIsFor
        ) = _simpleMajority(tallyVotesFor, tallyVotesAgainst);
        // Checks if a simple majority was reached for votes and weight
        if(
            votesReached == false ||
            weightReached == false
        ) {
            return (false, false);
        }
        // Checks if the vote passed for
        if(
            voteIsFor &&
            weightIsFor
        ) {
            return (true, true);
        }
        // Otherwise vote failed (is against)
        return (true, false);
    }

    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS

    function executeProposal(uint256 _propID) external {
        _isCurrent();

        require(
           storageImp_.isProposalInVoteWindow(_propID) == false,
           "Cannot execute while vote open"
        );
        // Checking consensus was reached
        (
            bool consensusReached,
            bool isPassed
        ) = this.doesElectionReachConsensus(_propID);
        require(
           consensusReached && isPassed,
           "Consensus not reached"
        );

        // TODO call options registry to execute
    }

    // -------------------------------------------------------------------------
    // INTERNAL FUNCTIONS

    function _simpleMajority(
        uint256 _for, 
        uint256 _against
    ) 
        internal 
        pure
        returns(
            bool majorityReached,
            bool isFor
        ) 
    {
        if(_for > _against) {
            return(true, true);
        } else if(_against > _for) {
            return(true, false);
        }
        return (false, false);
    }

    function _minEngagementReached(uint256 _propID) internal view returns(bool) {
        (
            uint256 totalVotes,
            uint256 totalWeight
        ) = storageImp_.getProposalElectionTotals(_propID);
        if(
            totalVotes >= minimumVotes &&
            totalWeight >= minimumWeight
        ) {
            return true;
        }
        return false;
    }

    function _isCurrent() internal {
        address received = voteCoImp_.getStorage();
        if(address(storageImp_) != received) {
            storageImp_ = VoteStorage(received);
        }
    }
}