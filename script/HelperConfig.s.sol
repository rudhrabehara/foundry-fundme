// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import {Script} from "forge-std/Script.sol";  
import {MockV3Aggregator} from "../test/Mock/mockAggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig ;
    uint8 public constant Decimals = 8;
    int256 public constant initial_value = 2000e8;
    struct NetworkConfig {
        address priceFeed;
    }
    constructor (){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig(); 
        } else if(block.chainid == 1) { activeNetworkConfig = getEthMainnet();}
           else { activeNetworkConfig = getAnvilEthConfig();
        }
    }
    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig  = NetworkConfig({priceFeed :0x694AA1769357215DE4FAC081bf1f309aDC325306 });
        return sepoliaConfig;


    }
    function getAnvilEthConfig() public  returns(NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(Decimals,initial_value);
        vm.stopBroadcast();
        NetworkConfig memory mockConfig = NetworkConfig({priceFeed : address(mockPriceFeed)});
        return mockConfig;

    }
    function getEthMainnet() public pure returns(NetworkConfig memory) {
        NetworkConfig memory ethmainconfig = NetworkConfig({priceFeed :0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 });
        return ethmainconfig;
    }
    
} 