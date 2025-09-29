// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {FaucetFactory} from "../src/FaucetFactory.sol";
import {console} from "forge-std/console.sol";
contract DeployFaucetFactory is Script {
    function run() external returns(address ) {
        vm.startBroadcast();
        FaucetFactory factory = new FaucetFactory();
        vm.stopBroadcast();
        console.log("Factory deployed to:", address(factory));
        return address(factory);
    }
}