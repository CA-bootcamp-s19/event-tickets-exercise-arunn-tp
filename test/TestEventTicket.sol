pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/EventTickets.sol";
import "../contracts/EventTicketsV2.sol";

contract TestEventTicket {
	//escrow contract Balance for tests
    uint public initialBalance = 10 ether;

    uint constant TICKET_PRICE = 100 wei;

    struct DummyEvent{
        string description;
        string website;
        uint totalTickets;
        uint sales;
        bool isOpen;
    }

    DummyEvent eventA = DummyEvent("descriptionA", "URLA",100,0,true);

    function testOwnwer() public{
    	EventTickets testEvent = EventTickets(DeployedAddresses.EventTickets());
    	Assert.equal(testEvent.owner(),msg.sender,"Owner deploys the contract");
    }

    function testEventDescription() public{
    	EventTickets testEvent = new EventTickets(eventA.description, eventA.website, eventA.totalTickets);
    	(string memory description , string memory website, uint totalTickets, uint sales, bool isOpen) = testEvent.readEvent();
    	Assert.equal(description, eventA.description, "description of the event must match");
    }
    function testEventWebsite() public{
    	EventTickets testEvent = new EventTickets(eventA.description, eventA.website, eventA.totalTickets);
    	(string memory description , string memory website, uint totalTickets, uint sales, bool isOpen) = testEvent.readEvent();
    	Assert.equal(website, eventA.website, "website of the event must match");
    }
    function testEventtotalTickets() public{
    	EventTickets testEvent = new EventTickets(eventA.description, eventA.website, eventA.totalTickets);
    	(string memory description , string memory website, uint totalTickets, uint sales, bool isOpen) = testEvent.readEvent();
    	Assert.equal(totalTickets, eventA.totalTickets, "totalTickets of the event must match");
    }
    function testIsSaleOpen() public {
    	EventTickets testEvent = new EventTickets(eventA.description, eventA.website, eventA.totalTickets);
    	(string memory description , string memory website, uint totalTickets, uint sales, bool isOpen) = testEvent.readEvent();
    	Assert.equal(isOpen, true, "event must be open");
    }
    function testBuyTickets() public payable {
    	EventTickets testEvent = new EventTickets(eventA.description, eventA.website, eventA.totalTickets);
    	testEvent.buyTickets.value(TICKET_PRICE)(1);
    	(string memory description , string memory website, uint totalTickets, uint sales, bool isOpen) = testEvent.readEvent();
    	Assert.equal(sales, 1, "Sales should be equal to the number of tickets bought");
    }
    function testTicketReceived() public payable {
        EventTickets testEvent = new EventTickets(eventA.description, eventA.website, eventA.totalTickets);
        testEvent.buyTickets.value(TICKET_PRICE*2)(2);
        uint tickets = testEvent.getBuyerTicketCount(address(this));
        Assert.equal(tickets, 2, "The buyer should have the 2 tickets purchased");
    }
}