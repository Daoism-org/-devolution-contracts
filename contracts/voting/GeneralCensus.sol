// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

contract GeneralCensus {
    // TODO interface
    address internal voterCo_;
    // Consensus parameters
    // The minimum number of votes cast 
    uint256 public minimumVotes;

    constructor(
        address _voterCo,
        uint256 _minVotes,
        uint256 _minVoterEngagement,
        uint256 _minWeight
    ) {
        voterCo_ = _voterCo;
    }

    function canExecuteElectionResult(
        uint256 _propID
    ) 
        external 
        view 
        returns(bool) 
    {
        if(
            // election time expired
            // census reached
            true
        ) {
            return true;
        }
        return false;
    }

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
        // (
        //     uint256 tallyVotesFor,
        //     uint256 tallyWeightFor,
        //     uint256 tallyVotersFor,
        //     uint256 tallyVotesAgainst,
        //     uint256 tallyWeightAgainst,
        //     uint256 tallyVotersAgainst,
        //     uint256 expiry
        // ) = voterCo_.propInfo(_propID);

        // uint256 totalVotes = tallyVotesFor + tallyVotesAgainst;
        // uint256 totalWeight = tallyWeightFor + tallyWeightAgainst;
        // uint256 totalVoters = tallyVotersFor + tallyVotersAgainst;

        // Working out if election reaches minimum engagements requirements

    }
}