// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract EthFaucet is Pausable, ReentrancyGuard, Initializable {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 public dripAmount; // amount (token units or wei) per claim
    mapping(address => bool) public hasClaimed;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Claimed(address indexed user, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error ERC20Faucet__InsufficientFaucetBalance();

/*CONSTRUCTOR*/
        constructor() {
        _disableInitializers();
    }
    function initialize( uint256 _dripAmount, address[] memory policies) external initializer {
        dripAmount = _dripAmount;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function myFunction() public {
        // function logic here
    }
}