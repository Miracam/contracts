// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Push Communication Contract Interface
interface IPUSHCommInterface {
    function sendNotification(
        address _channel,
        address _recipient,
        bytes calldata _identity
    ) external;
}

contract BroadcastContract {
    // Address of the Push Communication contract for the specific blockchain
    address public pushCommContract;

    // Address of your Push channel
    address public channelAddress;

    // Event for tracking notifications
    event NotificationSent(string title, string body);

    // Constructor to set the Push Communication contract address and channel address
    constructor(address _pushCommContract, address _channelAddress) {
        pushCommContract = _pushCommContract;
        channelAddress = _channelAddress;
    }

    // Function to send a Push notification
    function broadcast(
        string memory title, // Notification title
        string memory body // Notification body
    ) public {
        // Ensure the Push Communication contract is set
        // require(pushCommContract != address(0), "PushCommContract address is not set");

        // Initialize the Push Communication contract interface
        IPUSHCommInterface pushComm = IPUSHCommInterface(0x6e489B7af21cEb969f49A90E481274966ce9D74d);

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

        // Emit an event for tracking
        emit NotificationSent(title, body);
    }

    // // Function to update the Push Communication contract address
    // function updatePushCommContract(address _newPushCommContract) public {
    //     require(_newPushCommContract != address(0), "Invalid PushCommContract address");
    //     pushCommContract = _newPushCommContract;
    // }

    // // Function to update the channel address
    // function updateChannelAddress(address _newChannelAddress) public {
    //     require(_newChannelAddress != address(0), "Invalid channel address");
    //     channelAddress = _newChannelAddress;
    // }
}
