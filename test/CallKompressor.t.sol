// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { FFIHarness } from "./utils/FFIHarness.sol";
import { CallKompressor } from "src/CallKompressor.sol";

/// @dev Tests for the `CallKompressor` contract.
contract CallKompressor_Test is FFIHarness {
    CallKompressor solKompressor;
    CallKompressor huffKompressor;

    function setUp() public {
        // Deploy a new `CallKompressor.sol`
        solKompressor = new CallKompressor();

        // Deploy a new `CallKompressor.huff`
        string[] memory commands = new string[](3);
        commands[0] = "huffc";
        commands[1] = "-b";
        commands[2] = "./src/CallKompressor.huff";
        bytes memory code = vm.ffi(commands);
        assembly {
            sstore(huffKompressor.slot, create(0x00, add(code, 0x20), mload(code)))
        }

        // Give ourselves some ETH to work with.
        vm.deal(address(this), type(uint128).max);
    }

    /// @dev Test call forwarding (Solidity)
    function testFuzz_forwardCallSol_succeeds(bytes memory _payload, uint128 _value) public {
        // Send the payload to the identity precompile
        address to = address(0x04);
        // Zero kompress the payload
        bytes memory compressed = zeroKompress(abi.encodePacked(to, _payload));

        vm.expectCall(to, _value, _payload);
        (bool success, bytes memory returndata) = address(solKompressor).call{ value: _value }(compressed);
        assertTrue(success);
        assertEq(returndata, _payload);
    }

    /// @dev Test call forwarding (Huff)
    function testFuzz_forwardCallHuff_succeeds(bytes memory _payload, uint128 _value) public {
        // Send the payload to the identity precompile
        address to = address(0x04);
        // Zero kompress the payload
        bytes memory compressed = zeroKompress(abi.encodePacked(to, _payload));

        vm.expectCall(to, _value, _payload);
        (bool success, bytes memory returndata) = address(solKompressor).call{ value: _value }(compressed);
        assertTrue(success);
        assertEq(returndata, _payload);
    }
}
