// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Streamer {
    address Owner;
    constructor() {
        Owner = payable(msg.sender); 
    }

    modifier OnlyOwner() {
        require(msg.sender == Owner, "only owner can access this function");
        _;
    }

    struct Event {
        uint256 id;
        address payable creater;
        string title;
        uint256 price; 
        uint256 Total_Price; 
        string streamLink;
        address[] participants;
        uint256[] amount;
    }

    mapping(uint256 => Event) public events;
    uint256 public eventCount = 0;

    // Function to create 
    function Create_event(string memory _title, string memory Stream_link, uint256 _price) public returns(uint256) {
        eventCount++;
        address[] memory NoParticipants;
        uint256[] memory noAmountCollected;
        events[eventCount] = Event({
            id: eventCount,
            creater: payable(msg.sender),
            title: _title,
            price: _price,
            Total_Price: _price + 1, 
            streamLink: Stream_link,
            participants: NoParticipants,
            amount: noAmountCollected
        });
        return eventCount;
    }

    function participate(uint256 event_id) public payable {
        require(event_id > 0 && event_id <= eventCount, "enter a valid event id");
        Event storage JoinEvent = events[event_id];
        uint256 money = msg.value;

        require(money == JoinEvent.Total_Price, "invalid ETH / Wei");
        uint256 creator_fee = JoinEvent.price;
        (bool success, ) = JoinEvent.creater.call{value: creator_fee}("");
        require(success, "failed to pay the event creator");

        uint256 company_fee = money - creator_fee;
        (bool company_payment, ) = Owner.call{value: company_fee}("");
        require(company_payment, "failed to pay the company");

        JoinEvent.participants.push(msg.sender);
        JoinEvent.amount.push(money);
    }

    function getParticipants(uint256 event_id) public view returns(address[] memory, uint256[] memory) {
        require(event_id > 0 && event_id <= eventCount, "Enter a valid event id");
        Event storage eventDetails = events[event_id];
        return (eventDetails.participants, eventDetails.amount);
    }

    function StakingMoney(uint256 event_id) public OnlyOwner {
        Event storage event_participants = events[event_id];
        uint256 CompanyMoneyStake = event_participants.Total_Price - event_participants.price;
        uint256 StakeAmount = CompanyMoneyStake/1000 ;
        for(uint participant = 0; participant <= event_participants.participants.length; participant++) {
            address Address_participant = event_participants.participants[participant];
            (bool Stake_Users, ) = Address_participant.call{value : StakeAmount}("");
            require(Stake_Users, "transaction failed");
        } 
    }
}
