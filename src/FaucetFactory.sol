// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {EthFaucet} from "./EthFaucet.sol";
import {ERC20Faucet} from "./ERC20Faucet.sol";

/**
 * @title FaucetFactory
 * @author Livingstone z.
 * @notice Deterministic Faucet clones
 */
contract FaucetFactory {
    /*//////////////////////////////////////////////////////////////
                                 TYPES
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    address public immutable i_EthFaucetImplementation;
    address public immutable i_Erc20FaucetImplementation;
    mapping(address => mapping(uint8 => address)) public userFaucetClone;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error FaucetFactory__FaucetAlreadyCreated();
    error FaucetFactory__ETHFaucetFailedToInitialize();

    /*CONSTRUCTOR*/
    constructor() {
        i_EthFaucetImplementation = address(new EthFaucet());
        i_Erc20FaucetImplementation = address(new ERC20Faucet());
    }

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function createEthFaucet(uint256 _dripAmount, address[] memory policies) public returns (address faucet) {
        if (userFaucetClone[msg.sender][0] != address(0)) revert FaucetFactory__FaucetAlreadyCreated();
        bytes32 salt = keccak256(abi.encodePacked(msg.sender));
        address predictedAddress = Clones.predictDeterministicAddress(i_EthFaucetImplementation, salt);
        if (predictedAddress.code.length != 0) revert FaucetFactory__FaucetAlreadyCreated();
        faucet = Clones.cloneDeterministic(i_EthFaucetImplementation, salt);
        userFaucetClone[msg.sender][0] = faucet;
        try EthFaucet(payable(faucet)).initialize(_dripAmount, policies) {}
        catch {
            revert FaucetFactory__ETHFaucetFailedToInitialize();
        }
    }

    function createErc20Faucet(address _token, uint256 _dripAmount, address[] memory policies)
        public
        returns (address)
    {
        if (userFaucetClone[msg.sender][1] != address(0)) revert FaucetFactory__FaucetAlreadyCreated();
        bytes32 salt = keccak256(abi.encodePacked(msg.sender));
        address predictedAddress = Clones.predictDeterministicAddress(i_Erc20FaucetImplementation, salt);
        if (predictedAddress.code.length != 0) revert FaucetFactory__FaucetAlreadyCreated();
        address faucet = Clones.cloneDeterministic(i_Erc20FaucetImplementation, salt);
        userFaucetClone[msg.sender][1] = faucet;
        try ERC20Faucet(payable(faucet)).initialize(_token, _dripAmount, policies) {}
        catch {
            revert FaucetFactory__ETHFaucetFailedToInitialize();
        }
    }
}
