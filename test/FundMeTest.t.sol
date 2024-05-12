//SPDX-License-Identifier: MIT 
pragma solidity ^0.8.23;

import {Test,console} from "forge-std/test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
contract FundMeTest  is StdCheats,Test {
    FundMe fundme;
    HelperConfig helperconfig;
    uint256 number = 1;
    uint256  public constant SEND_VALUE = 0.1 ether;
    address  public constant USER = address(1);
    uint public constant STARTING_USER_BALANCE = 10 ether;
    function setUp()  external {
         DeployFundMe deployFundMe = new DeployFundMe();
         (fundme,helperconfig) = deployFundMe.run();
         vm.deal(USER,STARTING_USER_BALANCE);
    }
    function testMinimumDollarIsFive() view public {
    assertEq(fundme.MINIMUM_USD(),5e18);
    }
    function testOwnerIsMsgSender() view  public {
        assertEq(fundme.i_owner(),msg.sender);
    }
    function testPriceFeedVersionIsAccurate() view  public {
        uint256 version = fundme.getVersion();
        assertEq(version,4);
    }
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundme.fund();
    }
    function testFundUpdatesFundedDataStructure () public {
        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();
        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded,SEND_VALUE);
    }
    function testAddsFunderToArrayOfFunders() external {
        vm.startPrank(USER);
        fundme.fund{value:SEND_VALUE}();
        vm.stopPrank();
       address funder = fundme.getFunder(0);
       assertEq(funder, USER);
    } 
    modifier funded() {
        vm.prank(USER);
        fundme.fund{value:SEND_VALUE}();
        assert(address(fundme).balance > 0);
        _;
    }
    function testOnlyOwnerCanWithdraw() external funded{
        vm.expectRevert();
        vm.prank(USER);
        fundme.withdraw();
    }
   function  testWithdrawWithFunder () public {
         uint256 startingBalanceofOwner = fundme.i_owner().balance;
         uint256 startingbalanceofFundme = address(fundme).balance;
         vm.prank(fundme.i_owner());
         fundme.withdraw();
         uint endingbalanceofOwner = fundme.i_owner() .balance;
         uint endingbalanceOfFundme = address(fundme).balance;
         assertEq(endingbalanceofOwner,startingBalanceofOwner+startingbalanceofFundme);
         assertEq(endingbalanceOfFundme,0);
    }
    function testWithdrawWithMultipleFunders () public {
        uint160 startingIndex = 0;
        uint256 numberOfFunders = 10;
        for(uint160 i = startingIndex;i<numberOfFunders;i++){
            hoax(address(i),STARTING_USER_BALANCE);
            fundme.fund{value:SEND_VALUE}();
        }
        uint256 startingBalanceofOwner = fundme.i_owner().balance;
        uint256 startingBalanceofFundme = address(fundme).balance;
        vm.startPrank(fundme.i_owner());
        fundme.withdraw();
        vm.stopPrank();
        uint256 endingBalanceofOwner = fundme.i_owner().balance;
        uint256 endingBalanceofFundme = address(fundme).balance;
        assertEq(endingBalanceofOwner,startingBalanceofOwner+startingBalanceofFundme);
        assertEq(endingBalanceofFundme,0);

    }
}

