// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;
import "./P256.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
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

interface IPUSHCommInterface {
    function sendNotification(
        address _channel,
        address _recipient,
        bytes calldata _identity
    ) external;
}


contract MiracamNftMinter is Initializable {
    NFT public nft;
    Attester public attester;

   /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _nft, address _attester) public initializer {
        nft = NFT(_nft);
        attester = Attester(_attester);
    }

     function broadcast(
        string memory title, // Notification title
        string memory body // Notification body
    ) internal {
        // Ensure the Push Communication contract is set
        // require(pushCommContract != address(0), "PushCommContract address is not set");

        // Initialize the Push Communication contract interface
        IPUSHCommInterface pushComm = IPUSHCommInterface(0x6e489B7af21cEb969f49A90E481274966ce9D74d);
        address channelAddress = 0x4C7a0570D490539C3dDF767b7DFE995959d27Ed9;
        // Encode the notification identity
        bytes memory identity = abi.encodePacked(
            "0", // Minimal identity
            "+", // Separator
            "3", // Notification type: 1 (Broadcast), 3 (Targeted), or 4 (Subset)
            "+", // Separator
            title, // Notification title
            "+", // Separator
            body // Notification body
        );

        // Call the Push Communication contract to send the notification
        pushComm.sendNotification(channelAddress, channelAddress, identity);
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
        broadcast("Miracam NFT Minted", "A new Miracam NFT has been minted");
    }
}
