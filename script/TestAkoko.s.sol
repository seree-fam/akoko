// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Akoko.sol";  
import "../src/p256/verifier.sol";  
import "../src/tokens/tokens.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestAkoko is Script {
    function run() external {
        USDC usdc = new USDC(1000000000000000000);
        
        SignatureVerifier verifier = new SignatureVerifier();

        Akoko akoko = new Akoko(address(usdc), address(verifier));

        usdc.approve(address(akoko), 100 * 10**18);

        // 6066a610-d1bd-4b0a-b545-b72187955c77
        bytes32 uuid = 0x6066a610d1bd4b0ab545b72187955c7700000000000000000000000000000000;
        akoko.placeOrderUSDC(uuid, 100 * 10**18);

        bytes32 messageHash = 0x3db7e838b7eeab1010482ad619d4b41cba07808479b70316ed5de22c1c306b99;
        uint256 r = 100816060220007031888428484842947936857259693141652497073065119508515803340017;
        uint256 s = 34483173522907983957813985463722360567352391967806783363457853013752283257625;
        uint256 x = 3162615389638827008107058049378826219628830054367008622028789595109365031212;
        uint256 y = 88532558619310865306170076638353780591999590014174601125651589200412871357226;

        bool result = verifier.verify(messageHash, r, s, x, y);
        console.log("Signature verification result:", result);

        if (result) {
            akoko.payout(uuid, messageHash, r, s, x, y);
        }
    }
}