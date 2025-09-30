// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { BLS2 } from "./BLS2.sol";
import { HashToCurve } from "./HashToCurve.sol";

library BlsVerify {
    // point -G1.
    uint256 constant NEG_G1_X_HI = 0x17f1d3a73197d7942695638c4fa9ac0f;
    uint256 constant NEG_G1_X_LO = 0xc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb;
    uint256 constant NEG_G1_Y_HI = 0x114d1d6855d545a8aa7d76c8cf2e21f2;
    uint256 constant NEG_G1_Y_LO = 0x67816aef1db507c96655b9d5caac42364e6f38ba0ecb751bad54dcd6b939c2ca;

    // @notice Verify a BLS12-381 signature with a minimal-pubkey-size variant, compatible with Eth2.
    // @param pubKey Compressed public key on G1 curve (48 bytes)
    // @param sig Uncompressed signature on G2 curve (192 bytes)
    // @param message The message of arbitrary length
    // @param dst The domain separation tag
    // @return True if the signature is valid
    function verifyMinPubkeySize(
        bytes memory pubKey,
        bytes memory sig,
        bytes memory message,
        bytes memory dst
    ) public view returns (bool) {
        BLS2.PointG1 memory P = BLS2.g1UnmarshalCompressed(pubKey);
        BLS2.PointG2 memory S = BLS2.g2Unmarshal(sig);
        bytes32[8] memory H = HashToCurve.hashToCurveG2Array(message, dst);

        // Compute e(P, H) == e(-G1, S)
        uint256[24] memory input = [
          P.x_hi, P.x_lo, P.y_hi, P.y_lo,
          uint256(H[0]), uint256(H[1]), uint256(H[2]), uint256(H[3]), uint256(H[4]), uint256(H[5]), uint256(H[6]), uint256(H[7]),
          NEG_G1_X_HI, NEG_G1_X_LO, NEG_G1_Y_HI, NEG_G1_Y_LO,
          S.x0_hi, S.x0_lo, S.x1_hi, S.x1_lo, S.y0_hi, S.y0_lo, S.y1_hi, S.y1_lo
        ];
        uint256[1] memory out;
        bool success;
        assembly {
            success := staticcall(gas(), 0x0f, input, 768, out, 32)
        }
        return success && out[0] != 0;
    }
}