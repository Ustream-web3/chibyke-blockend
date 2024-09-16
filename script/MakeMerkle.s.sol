// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {Merkle} from "murky/src/Merkle.sol";
import {ScriptHelper} from "murky/script/common/ScriptHelper.sol";

contract MakeMerkle is Script, ScriptHelper {
    using stdJson for string;

    Merkle private m = new Merkle();

    string private inputPath = "/script/target/input.json";
    string private outputPath = "/script/target/output.json";

    string private elements = vm.readFile(string.concat(vm.projectRoot(), inputPath));
    string[] private types = elements.readStringArray(".types");
    uint256 private count = elements.readUint(".count");

    bytes32[] private leafs = new bytes32[](count);

    string[] private inputs = new string[](count);
    string[] private outputs = new string[](count);

    string private output;

    function getValuesByIndex(uint256 x, uint256 y) internal pure returns (string memory) {
        return string.concat(".values.", vm.toString(x), ".", vm.toString(y));
    }

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

    function run() public {
        console2.log("Generating Merkle Proof for %s", inputPath);

        for (uint256 a = 0; a < count; ++a) {
            string[] memory input = new string[](types.length);
            bytes32[] memory data = new bytes32[](types.length);

            for (uint256 b = 0; b < types.length; ++b) {
                if (compareStrings(types[b], "address")) {
                    address value = elements.readAddress(getValuesByIndex(a, b));
                    data[b] = bytes32(uint256(uint160(value)));
                    input[b] = vm.toString(value);
                } else if (compareStrings(types[b], "uint")) {
                    uint256 value = vm.parseUint(elements.readString(getValuesByIndex(a, b)));
                    data[b] = bytes32(value);
                    input[b] = vm.toString(value);
                }
            }

            leafs[a] = keccak256(bytes.concat(keccak256(ltrim64(abi.encode(data)))));

            inputs[a] = stringArrayToString(input);
        }

        for (uint256 a = 0; a < count; ++a) {
            string memory proof = bytes32ArrayToString(m.getProof(leafs, a));

            string memory root = vm.toString(m.getRoot(leafs));

            string memory leaf = vm.toString(leafs[a]);

            string memory input = inputs[a];

            outputs[a] = generateJsonEntries(input, proof, root, leaf);
        }

        output = stringArrayToArrayString(outputs);

        vm.writeFile(string.concat(vm.projectRoot(), outputPath), output);

        console2.log("DONE: The output is found at %s", outputPath);
    }
}
