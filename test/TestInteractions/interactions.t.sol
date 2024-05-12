// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract InteractionsTest is StdCheats,Test {
    FundMe public fundme;
    HelperConfig public helperconfig;
    uint256 public constant SEND_VALUE = 0.1 ether ;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;
    address public constant USER = address(1);

    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        (fundme,helperconfig) = deployer.run();
        vm.deal(USER,STARTING_USER_BALANCE);
    }
    function testUserCanFundOwnerWithdraw()public  {
        uint256 preUserBalance = USER.balance;
        uint256 preOwnerBalance = address(fundme.getOwner()).balance;
        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();
        WithdrawFundMe withdrawfundme = new WithdrawFundMe();
        withdrawfundme.withdrawFundMe(address(fundme));
         
         uint256 afterUserBalance = USER.balance;
         uint256 afterOwnerBalance = address(fundme.getOwner()).balance;
          
          assert(address(fundme).balance == 0);
          assertEq(preUserBalance, SEND_VALUE+afterUserBalance);
          assertEq(afterOwnerBalance,preOwnerBalance+SEND_VALUE);

    }

}
    