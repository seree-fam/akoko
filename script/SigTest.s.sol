// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "forge-std/Script.sol";
import "../src/p256/verifier.sol"; 

contract SigTestScript is Script {
    function run() external {
        address contractAddress = 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0;

        bytes32 messageHash = 0x3db7e838b7eeab1010482ad619d4b41cba07808479b70316ed5de22c1c306b99;
        uint256 r = 100816060220007031888428484842947936857259693141652497073065119508515803340017 ;
        uint256 s = 34483173522907983957813985463722360567352391967806783363457853013752283257625;
        uint256 x = 3162615389638827008107058049378826219628830054367008622028789595109365031212;
        uint256 y = 88532558619310865306170076638353780591999590014174601125651589200412871357226;

        SignatureVerifier ip256 = SignatureVerifier(contractAddress);

        bool result = ip256.verify(messageHash, r, s, x, y);

        console.log("Signature verification result:", result);
    }
}