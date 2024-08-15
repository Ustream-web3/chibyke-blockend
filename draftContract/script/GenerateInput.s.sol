// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract GenerateInput is Script {
    string types;
    uint256 count;
    string[] whitelist = new string[](4);
    string private constant INPUT_PATH = "/script/target/input.json";

    function run() public {
        types = "address";
        whitelist[0] = "0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D";
        whitelist[1] = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        whitelist[2] = "0x2ea3970Ed82D5b30be821FAAD4a731D35964F7dd";
        whitelist[3] = "0xf6dBa02C01AF48Cf926579F77C9f874Ca640D91D";
        count = whitelist.length;
        string memory input = _createJSON();
        // write to the output file the stringified output json tree dumpus
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        console2.log("DONE: The output is found at %s", INPUT_PATH);
    }

    function _createJSON() internal view returns (string memory) {
        // Convert the count of addresses to a string
        string memory countString = vm.toString(count);

        // Start the JSON string with the types and count fields
        string memory json = string.concat('{ "types": "address", "count":', countString, ',"values": {');

        // Loop through the whitelist and add each address to the JSON string
        for (uint256 i = 0; i < whitelist.length; i++) {
            // Concatenate each address with its index in the format "index": "address"
            json = string.concat(json, '"', vm.toString(i), '": "', whitelist[i], '"');

            // If it's not the last element, add a comma
            if (i < whitelist.length - 1) {
                json = string.concat(json, ",");
            }
        }

        // Close the JSON string
        json = string.concat(json, "} }");

        return json;
    }
}
