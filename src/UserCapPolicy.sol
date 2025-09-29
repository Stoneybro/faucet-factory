// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {IFaucetPolicy} from "./interfaces/IFaucetPolicy.sol";

contract UserCapPolicy is IFaucetPolicy {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/


    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    mapping (address => uint) userAmountClaimed;
    uint256 public immutable userCap;
    uint256 public immutable dripAmount;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/


/*CONSTRUCTOR*/
    constructor(uint256 _userCap, uint256 _dripAmount) {
        userCap = _userCap;
        dripAmount = _dripAmount;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function validateClaim(address user) public view override returns (bool) {
        return userAmountClaimed[user] < userCap;
    }
    function afterClaim(address user) public override {
        userAmountClaimed[user] += dripAmount;
    }
}