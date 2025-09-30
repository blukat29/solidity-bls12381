pragma solidity ^0.8;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { BLS2 } from "src/BLS2.sol";
import { HashToCurve } from "src/HashToCurve.sol";

contract BLSTest is Test {
    // Taken from https://github.com/ethereum/bls12-381-tests
    // verify/verify_valid_case_195246ee3bd3b6ec.json
    bytes testPubBytesCompressed = hex"b53d21a4cfd562c469cc81514d4ce5a6b577d8403d32a394dc265dd190b47fa9f829fdd7963afdf972e5e77854051f6f";
    bytes testSigBytesCompressed = hex"ae82747ddeefe4fd64cf9cedb9b04ae3e8a43420cd255e3c7cd06a8d88b7c7f8638543719981c5d16fa3527c468c25f0026704a6951bde891360c7e8d12ddee0559004ccdbe6046b55bae1b257ee97f7cdb955773d7cf29adf3ccbb9975e4eb9";
    bytes testMsgBytes = hex"abababababababababababababababababababababababababababababababab";
    bytes dst = "BLS_SIG_BLS12381G2_XMD:SHA-256_SSWU_RO_POP_";

    // Intermediate data calculated using '@noble/curves/bls12-381.js'
    bytes testSigBytesUncompressed = hex"0e82747ddeefe4fd64cf9cedb9b04ae3e8a43420cd255e3c7cd06a8d88b7c7f8638543719981c5d16fa3527c468c25f0026704a6951bde891360c7e8d12ddee0559004ccdbe6046b55bae1b257ee97f7cdb955773d7cf29adf3ccbb9975e4eb915e60d5b66a43e074b801a07df931a17505048f7f96dc80f857b638e505868dc008cc9c26ed5b8495e9c181b67dc4c2317d9d447337a9cc6d2956b9c6dd7c23c0bfb73855e902061bcb9cb9d40e43c38140091e638ffcffc7261366018900047";
    uint256[4] testPubPoint = [ // bls12_381.G1.Point.fromBytes(Buffer.from(pubHex,'hex'))
        0x153d21a4cfd562c469cc81514d4ce5a6,
        0xb577d8403d32a394dc265dd190b47fa9f829fdd7963afdf972e5e77854051f6f,
        0x14e22fd412a826a329fb40cbdc01b5e4,
        0xe2f931ed84d8e45932ec62a039f9d61a9dbf2c6eedc5db6fa585b6e0bdde100c
    ];
    // NOTE: The uncompressed bytes is in (x1 || x0 || y1 || y0) order. But EIP-2537 precompiles expect an array of (x0 || x1 || y0 || y1) order. Below arrays are in EIP-2537 order.
    uint256[8] testSigPoint = [ // bls12_381.G2.Point.fromBytes(Buffer.from(sigHex,'hex'))
        0x026704a6951bde891360c7e8d12ddee0,
        0x559004ccdbe6046b55bae1b257ee97f7cdb955773d7cf29adf3ccbb9975e4eb9,
        0x0e82747ddeefe4fd64cf9cedb9b04ae3,
        0xe8a43420cd255e3c7cd06a8d88b7c7f8638543719981c5d16fa3527c468c25f0,
        0x17d9d447337a9cc6d2956b9c6dd7c23c,
        0x0bfb73855e902061bcb9cb9d40e43c38140091e638ffcffc7261366018900047,
        0x15e60d5b66a43e074b801a07df931a17,
        0x505048f7f96dc80f857b638e505868dc008cc9c26ed5b8495e9c181b67dc4c23
    ];
    uint256[8] testMsgPoint = [ // bls12_381.longSignatures.hash(Buffer.from(msgHex,'hex'), dst)
        0x0bc0f071f2d0655a5edbf6b9208a6649,
        0xd3309b8692d2f55bde74c52cc2de0fed2bb60b4c45935b11c32827da1b80cb8f,
        0x179451d90ade914f7a6ffc5062914af9,
        0x90af297abdebf81dcebcaff93a5cb959e7f5db624bc8abb8cdb2660374c86a35,
        0x10bf383a073a41e693ccc01d380c040c,
        0x1aedae63e5ecca4bba4013638718e0f02a7656ffcb1f93c419483f820dc07129,
        0x0c2309a40a73adc91fb43fcb8589048e,
        0x0141616d978e120dc4d354b502d93fe74443dec6a00d1f80a487ed4bdfea41c2
    ];
    uint256[4] NEG_G1 = [ // bls12_381.G1.Point.BASE.negate()
        0x17f1d3a73197d7942695638c4fa9ac0f,
        0xc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb,
        0x114d1d6855d545a8aa7d76c8cf2e21f2,
        0x67816aef1db507c96655b9d5caac42364e6f38ba0ecb751bad54dcd6b939c2ca
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

    function test_HashToG2() public view {
        bytes32[8] memory h = HashToCurve.hashToCurveG2Array(testMsgBytes, dst);
        uint256[8] memory H;
        for (uint256 i = 0; i < 8; i++) {
            H[i] = uint256(h[i]);
        }
        assert(
            H[0] == testMsgPoint[0] &&
            H[1] == testMsgPoint[1] &&
            H[2] == testMsgPoint[2] &&
            H[3] == testMsgPoint[3] &&
            H[4] == testMsgPoint[4] &&
            H[5] == testMsgPoint[5] &&
            H[6] == testMsgPoint[6] &&
            H[7] == testMsgPoint[7]
        );
    }

    function test_Pairing() public view {
        // e(P, H) == e(-G1, S)
        uint256[4] memory P = testPubPoint;
        uint256[8] memory H = testMsgPoint;
        uint256[4] memory G = NEG_G1;
        uint256[8] memory S = testSigPoint;

        uint256[24] memory input = [
            P[0], P[1], P[2], P[3],
            H[0], H[1], H[2], H[3], H[4], H[5], H[6], H[7],
            G[0], G[1], G[2], G[3],
            S[0], S[1], S[2], S[3], S[4], S[5], S[6], S[7]
        ];
        console.log(input[0]);
        uint256[1] memory out;
        bool success;
        assembly {
            success := staticcall(gas(), 0x0f, input, 768, out, 32)
        }
        assert(success);
        assert(out[0] != 0);
    }
}
