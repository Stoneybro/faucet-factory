// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ERC20Faucet is ReentrancyGuard, Pausable, Initializable {
    using SafeERC20 for IERC20;
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IERC20 public token; // ERC20 token distributed by faucet. May be address(0) for ETH-only.
    uint256 public dripAmount; // amount (token units or wei) per claim
    mapping(address => bool) public hasClaimed;
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Claimed(address indexed user, uint256 amount);
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error ERC20Faucet__TokenAddressIsNotSet();
    error ERC20Faucet__InsufficientFaucetBalance();
    error ERC20Faucet__TransferFailed();

    /*CONSTRUCTOR*/
        constructor() {
        _disableInitializers();
    }
    function initialize( address _token, uint256 _dripAmount, address[] memory policies) external initializer {
        token = IERC20(_token);
        dripAmount = _dripAmount;
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function claimETH() external nonReentrant whenNotPaused {
        uint256 balance = address(this).balance;
        if (dripAmount > balance) revert ERC20Faucet__InsufficientFaucetBalance();

        hasClaimed[msg.sender] = true;

        (bool success,) = msg.sender.call{value: dripAmount}("");
        if (!success) revert ERC20Faucet__TransferFailed();

        emit Claimed(msg.sender, dripAmount);
    }
}
