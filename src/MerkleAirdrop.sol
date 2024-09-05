//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BagelToken} from "./BagelToken.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {MerkleProof} from "lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20;

    error MerkleAirdrop__InvalidMerkleProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    BagelToken public token;

    address[] claimers;
    bytes32 private immutable i_merkleRoot;
    IERC20 private immutable i_airdroptoken;

    mapping(address clamier => bool claimed) private s_hasClaimed;
    bytes32 private constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account, uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }
    event Claim(address account, uint256 amount);

    constructor(
        bytes32 merkleRoot,
        IERC20 airdroptoken
    ) EIP712("MerkleAirdrop", "1") {
        i_airdroptoken = airdroptoken;
        i_merkleRoot = merkleRoot;
    }

    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        if (!_isValidSignature(account, getMessage(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }
        bytes32 leaf = keccak256(
            bytes.concat(keccak256(abi.encode(account, amount)))
        );
        if (MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidMerkleProof();
        }
        s_hasClaimed[account] = true;
        emit Claim(account, amount);
        i_airdroptoken.safeTransfer(account, amount);
    }

    function getMessage(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({account: account, amount: amount})
                    )
                )
            );
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() public view returns (IERC20) {
        return i_airdroptoken;
    }

    function _isValidSignature(
        address signer,
        bytes32 digest,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal pure returns (bool) {
        // could also use SignatureChecker.isValidSignatureNow(signer, digest, signature)
        (address actualSigner, , ) = /*ECDSA.RecoverError recoverError*/
        /*bytes32 signatureLength*/
        ECDSA.tryRecover(digest, _v, _r, _s);
        return (actualSigner == signer);
    }
}
