//SPDX-License_Identifier: MIT

pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol"; 
contract FundMe{
     using SafeMathChainlink for uint256;//to overwrite overflows
      
      
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    
    address public owner;
    
    constructor() public{
        owner = msg.sender;// owner is this address
    }
    //payable = function could be used to pay for things
    //msg.sender = sender of the function call 
    //msg.value = how much they send
    function fund() public payable{
        uint256 minimumUSD = 50 * 10 ** 18;// 10** 18 = 10^18
        require(getConversionRate(msg.value) >= minimumUSD, "You need to spend more Eth");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        //what the Eth to USD conversion rate
        
    }
    function getVersion() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    function getPrice() public view returns(uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
       (,int256 answer,,,) = priceFeed.latestRoundData();
       return uint(answer * 1000000000); // to match the wei, gwei

    }
    
    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/ 1000000000000000000;
        return ethAmountInUsd;
    }

    function getEntranceFee() public view returns (uint256) {
        // mimimumUSD
        uint256 mimimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (mimimumUSD * precision) / price;
    }
    
    modifier onlyOwner{
         require(msg.sender == owner); 
         _;
    }
    
    //this = contract currently in
    //.balance views the balance
    function withdraw() payable onlyOwner public{
       
        msg.sender.transfer(address(this).balance);
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}