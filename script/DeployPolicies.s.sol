// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {GlobalCapPolicy} from "../src/GlobalCapPolicy.sol";
import {UserCapPolicy} from "../src/UserCapPolicy.sol";
import {MaxCooldownPolicy} from "../src/MaxCooldownPolicy.sol";
import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";

contract DeployPolicies is Script {
    function run() external returns (address , address , address ) {
        vm.startBroadcast();
        GlobalCapPolicy globalCapPolicy = new GlobalCapPolicy(2 ether, 0.1 ether);
        UserCapPolicy userCapPolicy = new UserCapPolicy(0.5 ether, 0.1 ether);
        MaxCooldownPolicy maxCooldownPolicy = new MaxCooldownPolicy(1 hours);
        vm.stopBroadcast();
        console.log("GlobalCapPolicy deployed to: ", address(globalCapPolicy));
        console.log("UserCapPolicy deployed to: ", address(userCapPolicy));
        console.log("MaxCooldownPolicy deployed to: ", address(maxCooldownPolicy));
        return (address(globalCapPolicy), address(userCapPolicy), address(maxCooldownPolicy));
    }
}