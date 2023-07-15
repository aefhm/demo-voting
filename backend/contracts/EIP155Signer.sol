// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Sapphire} from '@oasisprotocol/sapphire-contracts/contracts/Sapphire.sol';
import {EthereumUtils} from '@oasisprotocol/sapphire-contracts/contracts/EthereumUtils.sol';
import {RLPWriter} from "./RLPWriter.sol";

library EIP155Signer {
    struct EthTx {
        uint64 nonce;
        uint256 gasPrice;
        uint64 gasLimit;
        address to;
        uint256 value;
        bytes data;
        uint256 chainId;
    }

    struct SignatureRSV {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    function encodeSignedTx(EthTx memory rawTx, SignatureRSV memory rsv)
        internal view
        returns (bytes memory)
    {
        bytes[] memory b = new bytes[](9);
        b[0] = RLPWriter.writeUint(rawTx.nonce);
        b[1] = RLPWriter.writeUint(rawTx.gasPrice);
        b[2] = RLPWriter.writeUint(rawTx.gasLimit);
        b[3] = RLPWriter.writeAddress(rawTx.to);
        b[4] = RLPWriter.writeUint(rawTx.value);
        b[5] = RLPWriter.writeBytes(rawTx.data);
        b[6] = RLPWriter.writeUint((rsv.v - 27) + (block.chainid * 2) + 35);
        b[7] = RLPWriter.writeUint(uint256(rsv.r));
        b[8] = RLPWriter.writeUint(uint256(rsv.s));
        return RLPWriter.writeList(b);
    }

    function recoverV(address pubkey_addr, bytes32 digest, bytes32 r, bytes32 s)
        internal pure
        returns(uint8 v)
    {
        v = 27;

        if (ecrecover(digest, v, r, s) != pubkey_addr) {
            v = 28;

            if (ecrecover(digest, v, r, s) != pubkey_addr) {
                revert EthereumUtils.toEthereumSignature_Error();
            }
        }
    }

    function signRawTx(EthTx memory rawTx, address pubkey_addr, bytes32 sk)
        internal view
        returns (SignatureRSV memory ret)
    {
        bytes[] memory a = new bytes[](9);
        a[0] = RLPWriter.writeUint(rawTx.nonce);
        a[1] = RLPWriter.writeUint(rawTx.gasPrice);
        a[2] = RLPWriter.writeUint(rawTx.gasLimit);
        a[3] = RLPWriter.writeAddress(rawTx.to);
        a[4] = RLPWriter.writeUint(rawTx.value);
        a[5] = RLPWriter.writeBytes(rawTx.data);
        a[6] = RLPWriter.writeUint(rawTx.chainId);
        a[7] = RLPWriter.writeUint(0);
        a[8] = RLPWriter.writeUint(0);

        bytes32 a_digest = keccak256(RLPWriter.writeList(a));

        bytes memory sig = Sapphire.sign(Sapphire.SigningAlg.Secp256k1PrehashedKeccak256, abi.encodePacked(sk), abi.encodePacked(a_digest), "");

        (ret.r, ret.s) = EthereumUtils.splitDERSignature(sig);
        ret.v = recoverV(pubkey_addr, a_digest, ret.r, ret.s);
    }

    function sign(address publicAddress, bytes32 secretKey, EthTx memory transaction)
        internal view
        returns (bytes memory)
    {
        return EIP155Signer.encodeSignedTx(transaction, EIP155Signer.signRawTx(transaction, publicAddress, secretKey));
    }

    function generateKeypair()
        internal view
        returns (address pubkey_addr, bytes32 sk)
    {
        bytes memory rand_seed = Sapphire.randomBytes(32, "");
        sk = bytes32(rand_seed);
        (bytes memory pk, bytes memory tmp) = Sapphire.generateSigningKeyPair(Sapphire.SigningAlg.Secp256k1PrehashedKeccak256, rand_seed);
        pubkey_addr = EthereumUtils.k256PubkeyToEthereumAddress(pk);
    }
}