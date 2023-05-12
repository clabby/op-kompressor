// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ZeroDekompressorLib } from "./lib/ZeroDekompressorLib.sol";

/// @title CallKompressor
/// @author clabby <https://github.com/clabby>
contract CallKompressor {

    /// @dev When the `CallKompressor` receives a payload, it first decompresses it using
    /// `ZeroDekompressorLib.dekompressCalldata()`. Once the payload is decompressed, the
    /// `to` address as well as the payload are extracted in order to forward the call.
    ///
    /// The decompressed payload is expected to be in the following format:
    /// ╔═════════╤═══════════════════╗
    /// ║ Bytes   │ [0, 20)   [20, n) ║
    /// ╟─────────┼───────────────────╢
    /// ║ Element │ to        payload ║
    /// ╚═════════╧═══════════════════╝
    fallback() external payable {
        // Decompress the payload
        bytes memory decompressed = ZeroDekompressorLib.dekompressCalldata();

        // Extract the `to` address as well as the payload to forward
        assembly ("memory-safe") {
            // Forward the call
            let success :=
                call(
                    gas(), // Forward all gas
                    shr(0x60, mload(add(decompressed, 0x20))), // Extract the address (first 20 bytes)
                    callvalue(), // Forward the call value
                    add(decompressed, 0x34), // Extract the payload (skip the first 20 bytes)
                    sub(mload(decompressed), 0x14), // Extract the payload length (skip the first 20 bytes)
                    0x00, // Don't copy returndata
                    0x00 // Don't copy returndata
                )

            // Copy returndata to memory. It's okay that we clobber the free memory pointer here - it will
            // never be used again in this call context.
            returndatacopy(0x00, 0x00, returndatasize())

            // Bubble up the returndata
            switch success
            case true { return(0x00, returndatasize()) }
            case false { revert(0x00, returndatasize()) }
        }
    }
}
