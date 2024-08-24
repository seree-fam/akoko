// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "./verifier_help.sol"; 

contract SignatureVerifier {
    using P256 for bytes32;

    function verify(
        bytes32 messageHash,
        uint256 r,
        uint256 s,
        uint256 x,
        uint256 y
    ) public view returns (bool) {
        return messageHash.verifySignature(r, s, x, y);
    }
}