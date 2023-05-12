pragma solidity ^0.8.19;

import { FFIHarness } from "../utils/FFIHarness.sol";
import { ZeroDekompressorLib } from "src/lib/ZeroDekompressorLib.sol";

contract MockDekompressor {
    fallback() external {
        bytes memory d = ZeroDekompressorLib.dekompressCalldata();
        assembly {
            return(add(d, 0x20), mload(d))
        }
    }
}

contract ZeroDekompressorLib_Test is FFIHarness {
    MockDekompressor mockDekompressor;

    function setUp() public {
        mockDekompressor = new MockDekompressor();
    }

    function test_dekompressCalldata_empty() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"");
        assertTrue(success);
        assertEq(returndata, hex"");
    }

    /// @dev Test dekompression (static)
    function test_dekompressCalldata() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"7f6b590c0600220200");
        assertTrue(success);
        assertEq(returndata, hex"7f6b590c000000000000220000");
    }

    /// @dev Differential tests for dekompression against the Rust implementation
    function testDiff_dekompress(bytes memory _toCompress) public {
        bytes memory compressed = zeroKompress(_toCompress);

        (bool success, bytes memory returndata) = address(mockDekompressor).call(compressed);
        assertTrue(success);
        assertEq(returndata, zeroDekompress(compressed));
    }
}
