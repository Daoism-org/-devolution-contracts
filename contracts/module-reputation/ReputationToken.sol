// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "./IERC20.sol";
import "../base-implementations/modules/BaseSubModule.sol";

contract ReputationToken is IERC20, BaseSubModule {
    // Constant of this sub modules identifier
    bytes32 internal constant SubModuleIdentifier_ = "ReputationToken";
    // Explorer ID Token => Balances
    mapping(uint256 => uint256) internal balances_;
    // Owner => Spender => Approved Balances
    mapping (address => mapping (address => uint256)) private allowances_;

    uint256 private totalSupply_;

    string private name_;
    string private symbol_;
    uint8 private decimals_;

    constructor(address _baseModule) 
        BaseSubModule(SubModuleIdentifier_, _baseModule)
    {
        baseModule_ = IBaseModule(_baseModule);
    }

    function init() external override {
        // TODO needs to get the address of the executor from the base
        // module which is turn getting it from the spoke dao.
        // FIXME Get address of reputation distributor 
        // FIXME Get address of identity token to turn address into token ID
    }

    // -------------------------------------------------------------------------
    // NON-MODIFYING FUNCTIONS

    function allowance(
        address _owner, 
        address _spender
    ) 
        external 
        view 
        override
        returns(uint256)
    {
        // TODO Maybe use as proxy voting pattern? Would need a view function
        // where you could put in the token ID of the voter and get how many
        // tokens they have been approved to spend. Then only allow a person
        // to approve one address at a time. 
    }

    function totalSupply() external view override returns(uint256) {
        return totalSupply_;
    }

    function balanceOf(address _account) external view override returns(uint256) {
        uint256 ownedTokenID = 1; // FIXME needs to get from ID instance
        return balances_[ownedTokenID];
    }

    // -------------------------------------------------------------------------
    // STATE MODIFYING FUNCTIONS

    function registerOptionsOnModule() external override {

    }

    function mint(address _to, uint256 _amount) external {
        // TODO require only the reputation distributor can mint
    }

    function approve(address spender, uint256 amount) external override returns(bool) {
        // TODO maybe remove? Maybe use as indicator of proxy voting?
    }

    function transfer(
        address _recipient, 
        uint256 _amount
    ) 
        external 
        override
        returns(bool) 
    {
        require(
            true == false,
            "Cannot transfer reputation"
        );
    }

    function transferFrom(
        address sender, 
        address recipient, 
        uint256 amount
    ) 
        external 
        override
        returns(bool) 
    {
        require(
            true == false,
            "Cannot transfer reputation"
        );
    }

    // -------------------------------------------------------------------------
    // INTERNAL FUNCTIONS

}