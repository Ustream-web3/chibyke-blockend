// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

/**
 * @title GenerateInput Contract for JSON File Creation
 * @notice This contract generates a JSON file containing a whitelist of addresses and writes it to a specified path
 * @dev This contract is designed to be used with Foundry's scripting environment. It generates a JSON object with a list of addresses and saves it as an output file
 */
contract GenerateInput is Script {
    // >>--------------------->> VARIABLES
    ///@dev The type of data being stored in the JSON file, set to "address"
    string types;
    ///@dev The number of addresses in the whitelist
    uint256 count;
    ///@dev The array of whitelisted addresses to be included in the JSON file
    string[] whitelist = new string[](4);
    ///@dev The constant file path where the JSON file will be saved
    string private constant INPUT_PATH = "/script/target/input.json";

    /**
     * @notice Runs the script to generate a JSON file with whitelisted addresses
     * @dev This function sets up the whitelist, generates the JSON, and writes it to the specified file path
     * The script uses the Foundry's vm functionality to write to the file system
     */
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

    /**
     * @notice Creates a JSON string representing the whitelist of addresses
     * @dev This internal function converts the whitelist array into a JSON string format
     * @return A string containing the JSON representation of the whitelist
     */
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
