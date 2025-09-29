// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {IFaucetPolicy} from "./interfaces/IFaucetPolicy.sol";

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
    IFaucetPolicy[] public policies;
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event Claimed(address indexed user, uint256 amount);
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error ERC20Faucet__TokenAddressIsNotSet();
    error ERC20Faucet__InsufficientFaucetBalance();
    error ERC20Faucet__ValidationFailed();

    /*CONSTRUCTOR*/
    constructor() {
        _disableInitializers();
    }
    function initialize( address _token, uint256 _dripAmount, address[] memory _policies) external initializer {
        token = IERC20(_token);
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
            if (!policies[i].validateClaim(msg.sender)) revert ERC20Faucet__ValidationFailed();
        }
        uint256 balance = token.balanceOf(address(this));
        if (dripAmount > balance) revert ERC20Faucet__InsufficientFaucetBalance();

        hasClaimed[msg.sender] = true;

        token.safeTransfer(msg.sender, dripAmount);
        for (uint256 i = 0; i < policies.length; i++) {
            policies[i].afterClaim(msg.sender);
        }
        emit Claimed(msg.sender, dripAmount);
    }
}
