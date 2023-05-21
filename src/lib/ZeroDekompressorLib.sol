// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title ZerkDekompressorLib
/// @author clabby <https://github.com/clabby>
library ZeroDekompressorLib {
    /// @dev Thrown when the calldata is not correctly encoded.
    error InvalidInput();

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

                    // If the first byte is 0x00, we expect it to be RLE encoded. Skip over memory by `b2` bytes.
                    // Otherwise, copy the byte as normal.
                    switch iszero(b1)
                    case true {
                        // Perform a positive lookahead to determine the length of the zeros run.
                        let b2 := byte(0x01, chunk)

                        if iszero(b2) {
                            // Store the `InvalidInput()` selector in memory
                            mstore(0x00, 0xb4fa3fb3)
                            // Revert with the `InvalidInput()` selector
                            revert(0x1c, 0x04)
                        }

                        // Increment the calldata offset by 2 bytes to account for the RLE postfix and the zero byte.
                        cdOffset := add(cdOffset, 0x02)
                        // Increment the memory offset by `b2` bytes to retain `b2` zero bytes starting at `memOffset`.
                        memOffset := add(memOffset, b2)
                        // Increment the output length by `b2` bytes.
                        outLength := add(outLength, b2)
                    }
                    default {
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
