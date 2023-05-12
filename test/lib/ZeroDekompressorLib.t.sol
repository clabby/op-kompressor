// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { FFIHarness } from "../utils/FFIHarness.sol";
import { ZeroDekompressorLib } from "src/lib/ZeroDekompressorLib.sol";

/// @dev Tests for the `ZeroDekompressorLib` contract.
contract ZeroDekompressorLib_Test is FFIHarness {
    MockDekompressor mockDekompressor;

    function setUp() public {
        // Deploy a new `MockDekompressor`
        mockDekompressor = new MockDekompressor();
    }

    /// @dev Tests that the `dekompressCalldata` function returns a zero-length payload when
    /// called with an empty payload.
    function test_dekompressCalldata_empty_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"");
        assertTrue(success);
        assertEq(returndata, hex"");
        assertEq(returndata.length, 0);
    }

    /// @dev Test dekompression
    function test_dekompressCalldata_middle_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"7f6b590c0600220200ff");
        assertTrue(success);
        assertEq(returndata, hex"7f6b590c000000000000220000ff");
    }

    /// @dev Test dekompression
    function test_dekompressCalldata_edgeEnd_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"0400ff");
        assertTrue(success);
        assertEq(returndata, hex"00000000ff");
    }

    /// @dev Test dekompression
    function test_dekompressCalldata_edgeStart_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"ff0400");
        assertTrue(success);
        assertEq(returndata, hex"ff00000000");
    }

    /// @dev Test dekompression (zero rollover once)
    function test_dekompressCalldata_zeroRollover_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"ff000500");
        assertTrue(success);
        assertEq(
            returndata,
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
    }

    /// @dev Test dekompression (zero rollover multiple)
    function test_dekompressCalldata_zeroRolloverMultiple_succeeds() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"ff00ff000500");
        assertTrue(success);
        assertEq(
            returndata,
            hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        );
    }

    /// @dev Differential test for dekompression against the Rust implementation
    function testDiff_dekompress(bytes memory _toCompress) public {
        bytes memory compressed = zeroKompress(_toCompress);

        (bool success, bytes memory returndata) = address(mockDekompressor).call(compressed);
        assertTrue(success);
        assertEq(returndata, zeroDekompress(compressed));
    }
}

/// @dev A mock contract that calls `ZeroDekompressorLib` and returns the result.
contract MockDekompressor {
    fallback() external {
        bytes memory d = ZeroDekompressorLib.dekompressCalldata();
        assembly {
            return(add(d, 0x20), mload(d))
        }
    }
}
