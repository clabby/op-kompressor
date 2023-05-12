pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";

contract FFIHarness is Test {
    /// @dev ZeroKompresses the given bytes using the Rust sidecar.
    function zeroKompress(bytes memory _in) internal returns (bytes memory _out) {
        string[] memory commands = new string[](5);
        commands[0] = "./diff/target/release/diff";
        commands[1] = "--in-bytes";
        commands[2] = vm.toString(_in);
        commands[3] = "--mode";
        commands[4] = "zero-kompress";
        _out = vm.ffi(commands);
    }

    /// @dev ZeroDekompresses the given bytes using the Rust sidecar.
    function zeroDekompress(bytes memory _in) internal returns (bytes memory _out) {
        string[] memory commands = new string[](5);
        commands[0] = "./diff/target/release/diff";
        commands[1] = "--in-bytes";
        commands[2] = vm.toString(_in);
        commands[3] = "--mode";
        commands[4] = "zero-dekompress";
        _out = vm.ffi(commands);
    }
}
