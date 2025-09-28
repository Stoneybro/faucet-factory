// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
interface IFaucetPolicy {
    function validateClaim(address user) external view returns (bool);
    function afterClaim(address user) external;
}