pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { ZeroDekompressorLib } from "src/lib/ZeroDekompressorLib.sol";

contract MockDekompressor {
    fallback() external {
        bytes memory d = ZeroDekompressorLib.dekompressCalldata();
        assembly {
            return(add(d, 0x20), mload(d))
        }
    }
}

contract ZeroDekompressorLib_Test is Test {
    MockDekompressor mockDekompressor;

    function setUp() public {
        mockDekompressor = new MockDekompressor();
    }

    function test_dekompressCalldata_empty() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"");
        assertEq(returndata, hex"");
    }

    /// @dev Test dekompression (static)
    function test_dekompressCalldata() public {
        (bool success, bytes memory returndata) = address(mockDekompressor).call(hex"7f6b590c0600220200");
        assertEq(returndata, hex"7f6b590c000000000000220000");
    }
}
