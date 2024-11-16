// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import "./P256.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

interface NFT {
    function safeMint(address to, string memory uri) external;
}

interface Attester {
    function attesterOf(
        address account
    ) external view returns (string calldata);
}

contract MiracamNftMinter {
    NFT public nft;
    Attester public attester;

    constructor(address _nft, address _attester) {
        nft = NFT(_nft);
        attester = Attester(_attester);
    }

    function mint(
        // bytes32 hash,
        uint256 r,
        uint256 s,
        // uint256 x,
        // uint256 y,
        bytes calldata pubkeyBytes,
        address owner,
        string calldata url
    ) external 
    // string memory pubkey
    {
        bytes32 hash = sha256(abi.encodePacked("owner=", Strings.toHexString(owner), "&url=", url));
        uint256 x = uint256(bytes32(pubkeyBytes[1:33]));
        uint256 y = uint256(bytes32(pubkeyBytes[33:65]));
        require(
            P256.verifySignatureAllowMalleability(hash, r, s, x, y),
            "Invalid signature"
        );

        bytes memory attestedPubkey = bytes(attester.attesterOf(owner));
        bytes memory providedPubkey = bytes(Base64.encode(pubkeyBytes));
        require(keccak256(attestedPubkey) == keccak256(providedPubkey), "address not attested");
        nft.safeMint(owner, url);
    }
}
