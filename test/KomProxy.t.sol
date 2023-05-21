// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { FFIHarness } from "./utils/FFIHarness.sol";
import { KomProxy } from "src/KomProxy.sol";

contract KomProxy_Test is FFIHarness {
    KomProxy proxy;

    /// @dev Thrown when a function equipped with the `onlyOwner` modifier is called by an account
    ///      that is not the owner.
    error NotOwner();

    /// @notice Emitted when the ownership of the proxy is transferred.
    event OwnershipTransferred(address indexed _oldOwner, address indexed _newOwner);

    /// @notice Emitted when the implementation of the proxy is upgraded.
    event ImplementationUpgraded(address indexed _oldImpl, address indexed _newImpl);

    function setUp() public {
        // Deploy a new `KomProxy.sol` with the ID precompile as the implementation.
        proxy = new KomProxy(address(this), address(0x04));

        // Give the test contract some ETH to work with.
        vm.deal(address(this), type(uint128).max);
    }

    /// @dev Tests that `transferOwnership` succeeds if called by the owner.
    function test_transferOwnership_notOwner_reverts(address _sender, address _newOwner) public {
        vm.assume(_sender != address(this));

        vm.prank(_sender);
        vm.expectRevert(NotOwner.selector);
        proxy.transferOwnership(_newOwner);
    }

    /// @dev Tests that `transferOwnership` succeeds if called by the owner.
    function test_transferOwnership_succeeds(address _newOwner) public {
        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(address(this), _newOwner);
        proxy.transferOwnership(_newOwner);

        bytes32 owner = vm.load(address(proxy), bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1));
        assertEq(address(uint160(uint256(owner))), _newOwner);
    }

    /// @dev Tests that `upgradeImplementation` succeeds if called by the owner.
    function test_upgradeImplementation_notOwner_reverts(address _sender, address _newImpl) public {
        vm.assume(_sender != address(this));

        vm.prank(_sender);
        vm.expectRevert(NotOwner.selector);
        proxy.upgradeImplementation(_newImpl);
    }

    /// @dev Tests that `upgradeImplementation` succeeds if called by the owner.
    function test_upgradeImplementation_succeeds(address _newImpl) public {
        vm.expectEmit(true, true, false, false);
        emit ImplementationUpgraded(address(0x04), _newImpl);
        proxy.upgradeImplementation(_newImpl);

        bytes32 owner = vm.load(address(proxy), bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1));
        assertEq(address(uint160(uint256(owner))), _newImpl);
    }

    /// @dev Tests that the proxy properly forwards calls to the implementation.
    function test_fallback_succeeds(bytes calldata _payload, uint128 _value) public {
        if (_payload.length >= 4) {
            vm.assume(
                bytes4(_payload[0:4]) != proxy.transferOwnership.selector
                    && bytes4(_payload[0:4]) != proxy.upgradeImplementation.selector
            );
        }

        // Zero kompress the payload
        bytes memory compressed = zeroKompress(_payload);

        // Expect a delegate call to the ID precompile with the decompressed payload.
        vm.expectCall(address(0x04), 0, _payload);
        // Call the proxy with the compressed payload.
        (bool success, bytes memory returndata) = address(proxy).call{ value: _value }(compressed);

        // Assert that the call succeeded.
        assertTrue(success);
        // Assert that the proxy received the payload, decompressed it, and forwarded it to the ID precompile.
        assertEq(returndata, _payload);
        // Assert that the proxy received the balance.
        assertEq(address(proxy).balance, _value);
    }
}
