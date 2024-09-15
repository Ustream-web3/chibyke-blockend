// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";

contract GenerateInput is Script {
    uint256 private constant AMOUNT = 100e18;
    string[] types = new string[](2);
    uint256 count;
    string[] whitelist = new string[](4);
    string private constant INPUT_PATH = "/script/target/input.json";

    function run() public {
        types[0] = "address";
        types[1] = "uint256";
        whitelist[0] = "0xBf0b5A4099F0bf6c8bC4252eBeC548Bae95602Ea";
        whitelist[1] = "0x4dBa461cA9342F4A6Cf942aBd7eacf8AE259108C";
        whitelist[2] = "0xaF586d590DD21A2a76A091B3327C60C312D75539";
        whitelist[3] = "0x0efc4FbDBfB1500928cF198b18c6262f3E5333FC";
        count = whitelist.length;
        string memory input = _createJSON();

        // write to the output file the stringified output json tree dumpus
        vm.writeFile(string.concat(vm.projectRoot(), INPUT_PATH), input);

        console2.log("Done!!! The input can be found at %s", INPUT_PATH);
    }

    function _createJSON() internal view returns (string memory) {
        string memory countString = vm.toString(count); // convert count to string
        string memory amountString = vm.toString(AMOUNT); // convert amount to string
        string memory json = string.concat('{ "types": ["address", "uint256"], "count":', countString, ',"values": {');

        for (uint256 a = 0; a < whitelist.length; a++) {
            if (a == whitelist.length - 1) {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(a),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[a],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " }"
                );
            } else {
                json = string.concat(
                    json,
                    '"',
                    vm.toString(a),
                    '"',
                    ': { "0":',
                    '"',
                    whitelist[a],
                    '"',
                    ', "1":',
                    '"',
                    amountString,
                    '"',
                    " },"
                );
            }
        }

        json = string.concat(json, "} }");

        return json;
    }
}
