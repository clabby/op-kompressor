// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { FFIHarness } from "./utils/FFIHarness.sol";
import { CallKompressor } from "src/CallKompressor.sol";

/// @dev Tests for the `CallKompressor` contract.
contract CallKompressor_Test is FFIHarness {
    CallKompressor kompressor;

    function setUp() public {
        // Deploy a new `CallKompressor`
        kompressor = new CallKompressor();

        // Give ourselves some ETH to work with.
        vm.deal(address(this), type(uint128).max);
    }

    /// @dev Test call forwarding (static)
    function testFuzz_forwardCall_succeeds(bytes memory _payload, uint128 _value) public {
        // Send the payload to the identity precompile
        address to = address(0x04);
        // Zero kompress the payload
        bytes memory compressed = zeroKompress(abi.encodePacked(to, _payload));

        vm.expectCall(to, _value, _payload);
        (bool success, bytes memory returndata) = address(kompressor).call{ value: _value }(compressed);
        assertTrue(success);
        assertEq(returndata, _payload);
    }
}
