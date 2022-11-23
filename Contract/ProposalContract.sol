// SPDX-License-Identifier: MIT
//Interstellar Citizen Dao
pragma solidity ^0.8.7;

import "./Interface.sol";
import "./IERC20test.sol";

contract ProposalContract {

    INemberData NemberData;
    IERC20 ERC20;
    struct Proposal {
        address originators;
        string data;
        bool executed;
        uint starTime;
        uint timeLimited;
        uint numConfirmations;
    }
    //Proposal[] public proposalList;
    // mapping from proposal index => owner => bool
    //成员是否确认投票
    mapping(uint => mapping(address => bool)) public isConfirmed;
    mapping (uint => Proposal) public indexForProposal;

    uint public proposalCounter;

    constructor(address _NemberData, address _ERC20) {
        NemberData = INemberData(_NemberData);
        ERC20 = IERC20(_ERC20);
    }

    modifier onlyNember() {
        require(NemberData.isNember(msg.sender), "not nember");
        _;
    }

    modifier proposalExists(uint _proposalIndex) {
        require(_proposalIndex <= proposalCounter, "proposal does not exist");
        _;
    }

    modifier notExecuted(uint _proposalIndex) {
        require(!indexForProposal[_proposalIndex].executed, "proposal already executed");
        _;
    }

    modifier notConfirmed(uint _proposalIndex) {
        require(!isConfirmed[_proposalIndex][msg.sender], "proposal already confirmed");
        _;
    }

    modifier timeLimited(uint _proposalIndex) {
        require(block.timestamp - indexForProposal[_proposalIndex].starTime <= indexForProposal[_proposalIndex].timeLimited,"Out of time frame");
        _;
    }

    function _consumeToken(uint _amount) internal {
        ERC20.approve(msg.sender, address(this), _amount);
        ERC20.transferFrom(msg.sender, address(this), _amount);

    }
    //提交提案
    function submitProposal(
        string memory _data,
        uint _timeLimited
    ) public onlyNember {
        _consumeToken(10);
        proposalCounter ++;
        uint index = proposalCounter;

        indexForProposal[index].originators = msg.sender;
        indexForProposal[index].data = _data;
        indexForProposal[index].starTime = block.timestamp;
        indexForProposal[index].timeLimited = _timeLimited;


        
    }
    //确认提案
    function confirmproposal(uint _proposalIndex)
        public
        onlyNember
        proposalExists(_proposalIndex)
        notExecuted(_proposalIndex)
        notConfirmed(_proposalIndex)
        timeLimited(_proposalIndex)
    {
        Proposal storage proposal = indexForProposal[_proposalIndex];
        proposal.numConfirmations += 1;
        isConfirmed[_proposalIndex][msg.sender] = true;

        //emit Confirmproposal(msg.sender, _proposalIndex);
    }
    //取消确认
    function revokeConfirmation(uint _proposalIndex)
        public
        onlyNember
        proposalExists(_proposalIndex)
        notExecuted(_proposalIndex)
        timeLimited(_proposalIndex)
    {
        Proposal storage proposal = indexForProposal[_proposalIndex];

        require(isConfirmed[_proposalIndex][msg.sender], "proposal not confirmed");

        proposal.numConfirmations -= 1;
        isConfirmed[_proposalIndex][msg.sender] = false;

        //emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function executeProposal(uint _proposalIndex)
        public
        onlyNember
        proposalExists(_proposalIndex)
        notExecuted(_proposalIndex)
    {
        Proposal storage proposal = indexForProposal[_proposalIndex];

        require(1>0
            //执行条件待补充
            //proposal.numConfirmations >= numConfirmationsRequired,
            ,"cannot execute proposal"
        );

        proposal.executed = true;

        //执行逻辑
        
        require(1>0/*执行成功条件*/ ,"tx failed");

        //emit ExecuteTransaction(msg.sender, _txIndex);
    }


}
