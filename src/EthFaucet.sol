// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IFaucetPolicy} from "./interfaces/IFaucetPolicy.sol";
contract EthFaucet is Pausable, ReentrancyGuard, Initializable {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    uint256 public dripAmount; // amount (token units or wei) per claim
    mapping(address => bool) public hasClaimed;
    IFaucetPolicy[] public policies;
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Claimed(address indexed user, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error EthFaucet__InsufficientFaucetBalance();
    error EthFaucet__TransferFailed();
    error EthFaucet__ValidationFailed();
    /*CONSTRUCTOR*/
    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 _dripAmount, address[] memory _policies) external initializer {
        dripAmount = _dripAmount;
        for (uint256 i = 0; i < _policies.length; i++) {
            policies.push(IFaucetPolicy(_policies[i]));
        }
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function claim() external nonReentrant whenNotPaused {
        for (uint256 i = 0; i < policies.length; i++) {
            if (!policies[i].validateClaim(msg.sender)) revert EthFaucet__ValidationFailed();
        }
        uint256 balance = address(this).balance;
        if (dripAmount > balance) revert EthFaucet__InsufficientFaucetBalance();

        hasClaimed[msg.sender] = true;

        (bool success,) = payable(msg.sender).call{value:dripAmount}("");
        if (!success) revert EthFaucet__TransferFailed();
        for (uint256 i = 0; i < policies.length; i++) {
            policies[i].afterClaim(msg.sender);
        }
        emit Claimed(msg.sender, dripAmount);
    }
    receive() external payable {}
}
