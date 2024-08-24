// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/Akoko_eth.sol";

contract AkokoScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address contractAddress = address(0x10846782C728a193102A7cf3a7c40E2071Ebc958);
        Akoko ako = Akoko(payable(contractAddress));
        
        // 6059a610-d1bd-4b0a-b545-b72187949c91
        bytes32 uuid = 0x6059a610d1bd4b0ab545b72187949c9100000000000000000000000000000000;
        uint256 recipient = 233593456789;

        ako.placeOrder{value: 0.0001 ether}(uuid, recipient);

        vm.stopBroadcast();
    }

    function uuidToUint(string memory _uuid) internal pure returns (uint256) {
        bytes memory uuidBytes = bytes(_uuid);
        bytes memory cleanedBytes = new bytes(32); 
        uint256 j = 0;

        for (uint256 i = 0; i < uuidBytes.length; i++) {
            if (uuidBytes[i] != "-") {
                cleanedBytes[j] = uuidBytes[i];
                j++;
            }
        }

        return bytesToUinttwofivesix(cleanedBytes);
    }

    function bytesToUinttwofivesix(bytes memory b) internal pure returns (uint256) {
        uint256 number;
        for (uint256 i = 0; i < b.length; i++) {
            number = number * 16 + uint8(b[i]) - (uint8(b[i]) >= 97 ? 87 : uint8(b[i]) >= 65 ? 55 : 48);
        }
        return number;
    }
}