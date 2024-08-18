// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

// Merkle proof generator script
// To use:
// 1. Run `forge script script/GenerateInput.s.sol` to generate the input file
// 2. Run `forge script script/Merkle.s.sol`
// 3. The output file will be generated in /script/target/output.json

/**
 * @title MakeMerkle
 * @author Chukwubuike Victory Chime
 *
 * Original Work by:
 * @author kootsZhin
 * @notice https://github.com/dmfxyz/murky
 */
contract MakeMerkle is Script, ScriptHelper {
    using stdJson for string; // enables us to use the json cheatcodes for strings

    Merkle private m = new Merkle(); // instance of the merkle contract from Murky to do shit

    string private inputPath = "/script/target/input.json";
    string private outputPath = "/script/target/output.json";

    string private elements = vm.readFile(string.concat(vm.projectRoot(), inputPath)); // get the absolute path
    string private elementType = elements.readString(".types"); // single type: "address"
    uint256 private count = elements.readUint(".count"); // get the number of leaf nodes

    // Arrays to hold the leaf nodes and the stringified inputs
    bytes32[] private leafs = new bytes32[](count);
    string[] private inputs = new string[](count);
    string[] private outputs = new string[](count);

    string private output;

    /// @dev Returns the JSON path of the input file
    // output file output ".values.some-address"
    function getValuesByIndex(uint256 i) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(i));
    }

    /// @dev Generate the JSON entries for the output file
    function generateJsonEntries(string memory _inputs, string memory _proof, string memory _root, string memory _leaf)
        internal
        pure
        returns (string memory)
    {
        string memory result = string.concat(
            "{",
            "\"inputs\":",
            _inputs,
            ",",
            "\"proof\":",
            _proof,
            ",",
            "\"root\":\"",
            _root,
            "\",",
            "\"leaf\":\"",
            _leaf,
            "\"",
            "}"
        );

        return result;
    }

    /// @dev Read the input file and generate the Merkle proof, then write the output file
    function run() public {
        console2.log("Generating Merkle Proof for %s", inputPath);

        for (uint256 i = 0; i < count; ++i) {
            string memory input; // stringified data (address as string)
            bytes32 data; // actual data as bytes32

            if (compareStrings(elementType, "address")) {
                address value = elements.readAddress(getValuesByIndex(i));
                data = bytes32(uint256(uint160(value))); // Convert address to bytes32
                input = vm.toString(value); // Convert address to string
            }

            // Create the hash for the Merkle tree leaf node
            leafs[i] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));
            // Store the stringified input (address)
            inputs[i] = input;
        }

        for (uint256 i = 0; i < count; ++i) {
            // Get the Merkle proof and stringify
            string memory proof = bytes32ArrayToString(m.getProof(leafs, i));
            // Get the root hash and stringify
            string memory root = vm.toString(m.getRoot(leafs));
            // Get the specific leaf being processed and stringify
            string memory leaf = vm.toString(leafs[i]);
            // Get the stringified input (address)
            string memory input = inputs[i];

            // Generate the JSON output for this entry
            outputs[i] = generateJsonEntries(input, proof, root, leaf);
        }

        // Stringify the array of outputs
        output = stringArrayToArrayString(outputs);
        // Write the output to the JSON file
        vm.writeFile(string.concat(vm.projectRoot(), outputPath), output);

        console2.log("DONE: The output is found at %s", outputPath);
    }
}
