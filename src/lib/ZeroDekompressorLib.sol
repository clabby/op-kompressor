// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title ZerkDekompressorLib
/// @author clabby <https://github.com/clabby>
library ZeroDekompressorLib {
    /// @notice Decodes ZeroKompressed calldata into memory.
    /// @return _out The uncompressed calldata in memory.
    function dekompressCalldata() internal pure returns (bytes memory _out) {
        assembly ("memory-safe") {
            // If the input is empty, return an empty output.
            // By default, `_out` is set to the zero offset (0x60), so we only branch once rather than creating a
            // switch statement.
            if calldatasize() {
                // Grab some free memory for the output
                _out := mload(0x40)

                // Store the total length of the output on the stack and increment as we loop through the calldata
                let outLength := 0x00

                // Loop through the calldata
                for {
                    let cdOffset := 0x00
                    let memOffset := add(_out, 0x20)
                } lt(cdOffset, calldatasize()) { } {
                    // Load the current chunk
                    let chunk := calldataload(cdOffset)
                    // Load the first byte of the current chunk
                    let b1 := byte(0x00, chunk)
                    // Load the second byte of the current chunk
                    let b2 := byte(0x01, chunk)

                    // If the second byte is 0x00, we expect it to be RLE encoded. Skip over memory by `b1` bytes.
                    // Otherwise, copy the byte as normal.
                    switch and(iszero(b2), lt(add(cdOffset, 0x01), calldatasize()))
                    case true {
                        // Increment the calldata offset by 2 bytes to account for the RLE prefix and the zero byte.
                        cdOffset := add(cdOffset, 0x02)
                        // Increment the memory offset by `b1` bytes to retain `b1` zero bytes starting at `memOffset`.
                        memOffset := add(memOffset, b1)
                        // Increment the output length by `b1` bytes.
                        outLength := add(outLength, b1)
                    }
                    case false {
                        // Store the non-zero byte in memory at the current `memOffset`
                        mstore8(memOffset, b1)

                        // Increment the calldata offset by 1 byte to account for the non-zero byte.
                        cdOffset := add(cdOffset, 0x01)
                        // Increment the memory offset by 1 byte to account for the non-zero byte we just wrote.
                        memOffset := add(memOffset, 0x01)
                        // Increment the output length by 1 byte.
                        outLength := add(outLength, 0x01)
                    }
                }

                // Set the length of the output to the calculated length
                mstore(_out, outLength)

                // Update the free memory pointer
                mstore(0x40, add(_out, and(add(outLength, 0x3F), not(0x1F))))
            }
        }
    }
}
