pragma solidity ^0.8;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";

import { BLS2 } from "src/BLS2.sol";

contract BLSTest is Test {
    // https://github.com/ethereum/bls12-381-tests
    // verify/verify_valid_case_195246ee3bd3b6ec.json
    bytes testPubBytes = hex"b53d21a4cfd562c469cc81514d4ce5a6b577d8403d32a394dc265dd190b47fa9f829fdd7963afdf972e5e77854051f6f";

    // Intermediate data
    uint256[4] testPubPoint = [
        0x153d21a4cfd562c469cc81514d4ce5a6,
        0xb577d8403d32a394dc265dd190b47fa9f829fdd7963afdf972e5e77854051f6f,
        0x14e22fd412a826a329fb40cbdc01b5e4,
        0xe2f931ed84d8e45932ec62a039f9d61a9dbf2c6eedc5db6fa585b6e0bdde100c
    ];

    function test_UnmarshalPubkeyCompressed() public view {
        BLS2.PointG1 memory P = BLS2.g1UnmarshalCompressed(testPubBytes);
        assert(
            P.x_hi == testPubPoint[0] &&
            P.x_lo == testPubPoint[1] &&
            P.y_hi == testPubPoint[2] &&
            P.y_lo == testPubPoint[3]
        );
    }
}
