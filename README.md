## solidity-bls12381

**This code is not audited. Use at your own risk.**

On-chain BLS12-381 signature verification proof of concept.
- Powered by EIP-2537 precompiles.
- Supports minimal-pubkey-size variant, where pubkey on G1 and sig on G2.
- Supports minimal-signature-size variant, where pubkey on G2 and sig on G1.

See [BLS.t.sol](./test/BLS.t.sol) for usage.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

## Acknowledgements

This library is based on following works:
- [bls-solidity](https://github.com/randa-mu/bls-solidity) by @bbjubjub2494 for BLS2.sol.
- [bls12-381-hash-to-curve](https://github.com/ethyla/bls12-381-hash-to-curve) by @ethyla for HashToCurve.sol.
