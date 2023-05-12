<img align="right" width="150" height="150" top="100" src="./assets/logo.png">

# `op-kompressor` • [![tests](https://github.com/clabby/op-kompressor/actions/workflows/test.yml/badge.svg?label=tests)](https://github.com/clabby/op-kompressor/actions/workflows/test.yml) ![license](https://img.shields.io/github/license/clabby/op-kompressor?label=license)

> **Note**  
> This project has potential to reduce the costs of swaps and other transactions with large calldata payloads on L2s by a significant amount.
> It is intended to be used with ERC-4337 and other account abstraction methods, such as Gnosis Safes that allow for delegatecalling the `CallKompressor` contract.

`op-kompressor` is a suite of contracts that allows for relaying compressed abi-encoded payloads to L2 chains (like [Optimism](https://optimism.io)) where calldata is an expensive resource.

## `CallKompressor`

The `CallKompressor` (@ commit b9f239402e32afb0e01af6e7d8c073231e40df72) is deployed on [Optimism](https://optimism.io) @ [`0x6C56659A3EBE86394bF67889d860Fc74F404B867`](https://optimistic.etherscan.io/address/0x6c56659a3ebe86394bf67889d860fc74f404b867#code)

## Results
| Transaction                                                                                                                                | L1 Gas Usage | ZeroKompressed? |
|--------------------------------------------------------------------------------------------------------------------------------------------|--------------|-----------------|
| [Direct ID Uniswap Payload](https://optimistic.etherscan.io/tx/0xb19ff8aed6b293903c9a608ef0906c5d7c45087fa5646f5e7632685c231280c0)         | 8,828        | No              |
| [ZeroKompressed ID Uniswap Payload](https://optimistic.etherscan.io/tx/0x213e2b6a0ac0147f763220eb3accfcac2efea1b8988a1e9071b393ff14dd72b2) | 6,440        | Yes             |

## Compression Schemes
* [Run Length Encoding](https://en.wikipedia.org/wiki/Run-length_encoding) - RLE is great for Ethereum calldata because it's often the case that there are many repeated values in a given payload. The downside
  of RLE is that space efficiency for payloads with many unique values is poor. This is why `op-kompressor` supports a hybrid scheme that uses RLE for zero bytes (the most commonly repeated byte in calldata).
  For certain niche use cases, RLE may be a better choice than the hybrid scheme.
