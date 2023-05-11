<img align="right" width="150" height="150" top="100" src="./assets/logo.png">

# `op-kompressor` • [![tests](https://github.com/clabby/op-kompressor/actions/workflows/test.yml/badge.svg?label=tests)](https://github.com/clabby/op-kompressor/actions/workflows/test.yml) ![license](https://img.shields.io/github/license/clabby/op-kompressor?label=license)

> **Note**  
> This project is still in early development and is not yet ready for production use. It's kind of a shitpost, but it has potential to reduce the costs of swaps and other transactions
> with large calldata payloads on Optimism by a significant amount.

`op-kompressor` is a suite of contracts that allows for relaying compressed abi-encoded payloads to L2 chains (like [Optimism](https://optimism.io)) where calldata is an expensive resource.

## Compression Schemes
* [Run Length Encoding](https://en.wikipedia.org/wiki/Run-length_encoding) - RLE is great for Ethereum calldata because it's often the case that there are many repeated values in a given payload. The downside
  of RLE is that space efficiency for payloads with many unique values is poor. This is why `op-kompressor` supports a hybrid scheme that uses RLE for zero bytes (the most commonly repeated byte in calldata).
  For certain niche use cases, RLE may be a better choice than the hybrid scheme.

*TODO*
