// SPDX-License-Identifier: MIT

pragma solidity 0.7.6;

import "./IERC721.sol";

interface IExplorer is IERC721 {
    function isExplorer(address _explorer) external view returns(bool);

    function mint(address _to) external returns(uint256);
}