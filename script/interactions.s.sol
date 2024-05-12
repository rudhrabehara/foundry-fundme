// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import {Script,console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

contract FundFundMe is Script{
    uint256 SEND_VALUE = 0.1 ether;
    function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value:SEND_VALUE}();
        vm.stopBroadcast();
        console.log("funded fundme");
        }
    
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundME",block.chainid);
        fundFundMe(mostRecentlyDeployed);
    }
}
contract WithdrawFundMe is Script {
     uint256 SEND_VALUE = 0.1 ether;
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("withdraw fundme");
        }
    
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundME",block.chainid);
        withdrawFundMe(mostRecentlyDeployed);
    }
}
    
