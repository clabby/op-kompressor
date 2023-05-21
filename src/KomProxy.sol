// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { ZeroDekompressorLib } from "./lib/ZeroDekompressorLib.sol";

/// @title KomProxy
/// @author clabby <https://github.com/clabby>
contract KomProxy {
    /// @notice The storage slot that holds the address of the implementation.
    ///         bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
    bytes32 internal constant IMPLEMENTATION_KEY = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /// @notice The storage slot that holds the address of the owner.
    ///         bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
    bytes32 internal constant OWNER_KEY = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /// @notice Emitted when the ownership of the proxy is transferred.
    event OwnershipTransferred(address indexed _oldOwner, address indexed _newOwner);

    /// @notice Emitted when the implementation of the proxy is upgraded.
    event ImplementationUpgraded(address indexed _oldImpl, address indexed _newImpl);

    /// @dev A modifier to restrict a function's access control to the account that exists
    ///      in the `OWNER_KEY` slot.
    modifier onlyOwner() {
        assembly ("memory-safe") {
            if xor(caller(), sload(OWNER_KEY)) {
                // Store the "NotOwner()" selector in memory.
                mstore(0x00, 0x30cd7471)
                // Revert with "NotOwner()"
                revert(0x1c, 0x04)
            }
        }
        _;
    }

    /// @dev When the `KomProxy` is created, the deployer must initialize the Proxy by supplying both
    ///      an owner as well as an implementation contract.
    /// @param _owner The owner of the `KomProxy`
    /// @param _initialImplementation The initial implementation contract of the `KomProxy`
    constructor(address _owner, address _initialImplementation) {
        assembly ("memory-safe") {
            sstore(OWNER_KEY, _owner)
            sstore(IMPLEMENTATION_KEY, _initialImplementation)
        }
    }

    ////////////////////////////////////////////////////////////////
    //                       OWNER ACTIONS                        //
    ////////////////////////////////////////////////////////////////

    /// @notice Transfers the ownership of the proxy to a new address.
    /// @param _newOwner The new owner of the proxy.
    function transferOwnership(address _newOwner) external onlyOwner {
        address oldOwner;
        assembly ("memory-safe") {
            // Fetch the old owner for the event
            oldOwner := sload(OWNER_KEY)
            // Update the owner
            sstore(OWNER_KEY, _newOwner)
        }

        emit OwnershipTransferred(oldOwner, _newOwner);
    }

    /// @notice Upgrades the implementation of the proxy.
    /// @param _newImpl The new implementation address of the proxy.
    function upgradeImplementation(address _newImpl) external onlyOwner {
        address oldImpl;
        assembly ("memory-safe") {
            // Fetch the old implementation for the event
            oldImpl := sload(IMPLEMENTATION_KEY)
            // Update the implementation
            sstore(IMPLEMENTATION_KEY, _newImpl)
        }

        emit ImplementationUpgraded(oldImpl, _newImpl);
    }

    ////////////////////////////////////////////////////////////////
    //                         FALLBACKS                          //
    ////////////////////////////////////////////////////////////////

    /// @notice Proxy fallback function.
    fallback() external payable {
        _doProxyCall();
    }

    /// @notice Proxy fallback function.
    receive() external payable {
        _doProxyCall();
    }

    ////////////////////////////////////////////////////////////////
    //                         INTERNALS                          //
    ////////////////////////////////////////////////////////////////

    /// @notice Internal proxy fallback function.
    function _doProxyCall() internal {
        // Decompress the passed calldata payload prior to forwarding it to the implementation.
        bytes memory payload = ZeroDekompressorLib.dekompressCalldata();

        assembly ("memory-safe") {
            // Perform the delegatecall.
            let success :=
                delegatecall(gas(), sload(IMPLEMENTATION_KEY), add(payload, 0x20), mload(payload), 0x00, 0x00)

            // Copy the returndata into memory. This will overwrite the calldata we just wrote and potentially
            // clobber the free memory pointer, but this does not matter given that neither will be referenced
            // again within this context.
            returndatacopy(0x00, 0x00, returndatasize())

            // If the call succeeded, we want to return the bubbled up returndata. If not, we want
            // to revert with the bubbled up returndata.
            switch success
            case true { return(0x00, returndatasize()) }
            default { revert(0x00, returndatasize()) }
        }
    }
}
