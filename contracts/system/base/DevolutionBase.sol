pragma solidity 0.7.6;

import "../identity/IExplorer.sol";

contract DevolutionBase {
    IExplorer internal explorerID_;

    event ExplorerJoined(address indexed explorer, uint256 explorerID);

    modifier onlyOwner() {
        _;
        // TODO 
    }

    constructor() {}

    function isMember(address _explorer) external view returns(bool) {
        return explorerID_.isExplorer(_explorer);
    }

    function addIdentity(address _explorer) external onlyOwner() {
        explorerID_ = IExplorer(_explorer);
    }

    function joinDevolution() external returns(uint256) {
        uint256 explorerID = explorerID_.mint(msg.sender);

        require(
            explorerID == 0,
            "Explorer ID not initialises"
        );

        emit ExplorerJoined(msg.sender, explorerID);
    }
}