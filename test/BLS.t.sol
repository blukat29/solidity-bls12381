pragma solidity ^0.8;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { BLS2 } from "src/BLS2.sol";

contract BLSTest is Test {
    // Taken from https://github.com/ethereum/bls12-381-tests
    // verify/verify_valid_case_195246ee3bd3b6ec.json
    bytes testPubBytesCompressed = hex"b53d21a4cfd562c469cc81514d4ce5a6b577d8403d32a394dc265dd190b47fa9f829fdd7963afdf972e5e77854051f6f";
    bytes testSigBytesCompressed = hex"ae82747ddeefe4fd64cf9cedb9b04ae3e8a43420cd255e3c7cd06a8d88b7c7f8638543719981c5d16fa3527c468c25f0026704a6951bde891360c7e8d12ddee0559004ccdbe6046b55bae1b257ee97f7cdb955773d7cf29adf3ccbb9975e4eb9";

    // Intermediate data calculated using '@noble/curves/bls12-381.js'
    bytes testSigBytesUncompressed = hex"0e82747ddeefe4fd64cf9cedb9b04ae3e8a43420cd255e3c7cd06a8d88b7c7f8638543719981c5d16fa3527c468c25f0026704a6951bde891360c7e8d12ddee0559004ccdbe6046b55bae1b257ee97f7cdb955773d7cf29adf3ccbb9975e4eb915e60d5b66a43e074b801a07df931a17505048f7f96dc80f857b638e505868dc008cc9c26ed5b8495e9c181b67dc4c2317d9d447337a9cc6d2956b9c6dd7c23c0bfb73855e902061bcb9cb9d40e43c38140091e638ffcffc7261366018900047";
    uint256[4] testPubPoint = [
        0x153d21a4cfd562c469cc81514d4ce5a6,
        0xb577d8403d32a394dc265dd190b47fa9f829fdd7963afdf972e5e77854051f6f,
        0x14e22fd412a826a329fb40cbdc01b5e4,
        0xe2f931ed84d8e45932ec62a039f9d61a9dbf2c6eedc5db6fa585b6e0bdde100c
    ];
    // NOTE: The uncompressed bytes is in (x1 || x0 || y1 || y0) order. But EIP-2537 precompiles expect an array of (x0 || x1 || y0 || y1) order. Below arrays are in EIP-2537 order.
    uint256[8] testSigPoint = [
        0x026704a6951bde891360c7e8d12ddee0,
        0x559004ccdbe6046b55bae1b257ee97f7cdb955773d7cf29adf3ccbb9975e4eb9,
        0x0e82747ddeefe4fd64cf9cedb9b04ae3,
        0xe8a43420cd255e3c7cd06a8d88b7c7f8638543719981c5d16fa3527c468c25f0,
        0x17d9d447337a9cc6d2956b9c6dd7c23c,
        0x0bfb73855e902061bcb9cb9d40e43c38140091e638ffcffc7261366018900047,
        0x15e60d5b66a43e074b801a07df931a17,
        0x505048f7f96dc80f857b638e505868dc008cc9c26ed5b8495e9c181b67dc4c23
    ];

    function test_UnmarshalPub() public view {
        BLS2.PointG1 memory P = BLS2.g1UnmarshalCompressed(testPubBytesCompressed);
        assert(
            P.x_hi == testPubPoint[0] &&
            P.x_lo == testPubPoint[1] &&
            P.y_hi == testPubPoint[2] &&
            P.y_lo == testPubPoint[3]
        );
    }

    function test_UnmarshalSig() public view {
        BLS2.PointG2 memory S = BLS2.g2Unmarshal(testSigBytesUncompressed);
        assert(
            S.x0_hi == testSigPoint[0] &&
            S.x0_lo == testSigPoint[1] &&
            S.x1_hi == testSigPoint[2] &&
            S.x1_lo == testSigPoint[3] &&
            S.y0_hi == testSigPoint[4] &&
            S.y0_lo == testSigPoint[5] &&
            S.y1_hi == testSigPoint[6] &&
            S.y1_lo == testSigPoint[7]
        );
    }
}
