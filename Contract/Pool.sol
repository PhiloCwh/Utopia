pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Pool {
    IERC20 ERC20;
    uint public count;
    address public owner;
    uint public lastTime;
    uint public publicOneEthEarnings;
    uint public secondPrize = 50000000000000000000000;//每秒产出
    uint util = 1;

    mapping(address => uint) public userLastTimePrize;
    mapping(address => uint) public userOneEthPrize;
    mapping(address => uint) public userBalance;
    mapping(address => uint) public userInterest;
    mapping(address => uint) public hadGotToken;

    constructor(){
        owner = msg.sender;
        
    }

    receive() external payable {

    }

    function setERC20(address _ERC20)public {
        ERC20 = IERC20(_ERC20);
    }

    function Initialize (uint sprize) public {
        require(msg.sender == owner,"motherFuker");
        publicOneEthEarnings = findntPublicOneEthEarnings();
        lastTime = block.timestamp;
        secondPrize = sprize;
    }

    //查询公共一块钱奖励
    function findntPublicOneEthEarnings() public view returns(uint) {
        if(count == 0)
            return publicOneEthEarnings;
        return (publicOneEthEarnings + ((block.timestamp - lastTime) * secondPrize * util)/count);
    }

    function userPrize() public view returns(uint256) {
        if(userBalance[msg.sender] == 0)
            return 0;
        uint userOutput = (findntPublicOneEthEarnings() - userOneEthPrize[msg.sender]) / util;
        return (userBalance[msg.sender] * userOutput + userLastTimePrize[msg.sender]);
    }//userLastTimePrize[msg.sender]用户之前收益

    function stake() public payable {
        require(msg.value > 0, "msg.value >0");
        publicOneEthEarnings = findntPublicOneEthEarnings();
        lastTime = block.timestamp;
        userLastTimePrize[msg.sender] = userPrize();
        userOneEthPrize[msg.sender] = findntPublicOneEthEarnings();
        userBalance[msg.sender] += msg.value;
        count += msg.value;//总存款
    }

    function getToken() public {
        address user = msg.sender;
        uint amount = userPrize() - hadGotToken[user];
        ERC20.transfer(user, amount);
        hadGotToken[user] += amount;
    }

    function leftingTokenToClaim() public view returns(uint) {
        return userPrize() - hadGotToken[msg.sender];
    }



}
