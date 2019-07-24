pragma solidity ^0.5.0;

    /*
        The EventTicketsV2 contract keeps track of the details and ticket sales of multiple events.
     */
contract EventTicketsV2 {

    /*
        Define an public owner variable. Set it to the creator of the contract when it is initialized.
    */
    address public owner;
    


    uint   PRICE_TICKET = 100 wei;

    /*
        Create a variable to keep track of the event ID numbers.
    */
    uint public idGenerator;

    constructor ()
    public
    {
        owner = msg.sender;
        idGenerator = 0;
    }
    /*
        Define an Event struct, similar to the V1 of this contract.
        The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        Choose the appropriate variable type for each field.
        The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */
    struct Event{
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping (address => uint) buyers ;
        bool isOpen;
    }

    /*
        Create a mapping to keep track of the events.
        The mapping key is an integer, the value is an Event struct.
        Call the mapping "events".
    */
    mapping(uint => Event) events;

    event LogEventAdded(string desc, string url, uint ticketsAvailable, uint eventId);
    event LogBuyTickets(address buyer, uint eventId, uint numTickets);
    event LogGetRefund(address accountRefunded, uint eventId, uint numTickets);
    event LogEndSale(address owner, uint balance, uint eventId);

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier isOwner(){require(msg.sender == owner,"Operation not Authorized");_;}
    modifier isEventOpen(uint _eventId){require(events[_eventId].isOpen == true, "Event Closed");_;}
    modifier hasUserPaidEnough(uint _ticketCount){require(msg.value >= (PRICE_TICKET * _ticketCount),"Not enough moolah!");_;}
    modifier areThereEnoughTickets(uint _eventId, uint _ticketCount){require(events[_eventId].totalTickets - events[_eventId].sales > _ticketCount,"Out of tickets.");_;}
    modifier hasTheUserPurchasedTickets(uint _eventId){require(events[_eventId].buyers[msg.sender] > 0, "The user has not purchased any tickets.");_;}
    /*
        Define a function called addEvent().
        This function takes 3 parameters, an event description, a URL, and a number of tickets.
        Only the contract owner should be able to call this function.
        In the function:
            - Set the description, URL and ticket number in a new event.
            - set the event to open
            - set an event ID
            - increment the ID
            - emit the appropriate event
            - return the event's ID
    */
    function addEvent(string memory _description, string memory _URL, uint _numberOfTickets)
    isOwner()
    public
    returns (uint){
        uint eventId = idGenerator;
        events[eventId] = Event({
                                description: _description,
                                website: _URL,
                                totalTickets:_numberOfTickets,
                                sales:0,
                                isOpen:true
                                });
        idGenerator++;
        emit LogEventAdded(_description, _URL, _numberOfTickets, eventId);
        return eventId;
    }
    /*
        Define a function called readEvent().
        This function takes one parameter, the event ID.
        The function returns information about the event this order:
            1. description
            2. URL
            3. tickets available
            4. sales
            5. isOpen
    */
    function readEvent(uint _eventId)
    public
    view
    returns(string memory description, string memory URL, uint numberOfTickets, uint sales, bool isOpen ){
        return (events[_eventId].description, events[_eventId].website, events[_eventId].totalTickets, events[_eventId].sales, events[_eventId].isOpen);
    }
    /*
        Define a function called buyTickets().
        This function allows users to buy tickets for a specific event.
        This function takes 2 parameters, an event ID and a number of tickets.
        The function checks:
            - that the event sales are open
            - that the transaction value is sufficient to purchase the number of tickets
            - that there are enough tickets available to complete the purchase
        The function:
            - increments the purchasers ticket count
            - increments the ticket sale count
            - refunds any surplus value sent
            - emits the appropriate event
    */
    function buyTickets(uint _eventId, uint _ticketCount)
    isEventOpen(_eventId)
    hasUserPaidEnough(_ticketCount)
    areThereEnoughTickets(_eventId, _ticketCount)
    public
    payable
    returns(bool){
        events[_eventId].buyers[msg.sender] += _ticketCount;
        events[_eventId].sales += _ticketCount;
        uint refundAmount = msg.value - (_ticketCount * PRICE_TICKET);
        if(refundAmount > 0){
                msg.sender.transfer(refundAmount);
            }
        emit LogBuyTickets(msg.sender, _eventId, _ticketCount);
        return true;
    }
    /*
        Define a function called getRefund().
        This function allows users to request a refund for a specific event.
        This function takes one parameter, the event ID.
        TODO:
            - check that a user has purchased tickets for the event
            - remove refunded tickets from the sold count
            - send appropriate value to the refund requester
            - emit the appropriate event
    */
    function getRefund(uint _eventId)
    hasTheUserPurchasedTickets(_eventId) 
    public
    returns (bool)
    {
        uint refundedTickets = events[_eventId].buyers[msg.sender];
        uint refundAmount = refundedTickets * PRICE_TICKET;
        events[_eventId].sales -= refundedTickets;
        msg.sender.transfer(refundAmount);
        emit LogGetRefund(msg.sender, _eventId, refundedTickets);
        return true;
    }
    /*
        Define a function called getBuyerNumberTickets()
        This function takes one parameter, an event ID
        This function returns a uint, the number of tickets that the msg.sender has purchased.
    */
    function getBuyerNumberTickets(uint _eventId)
    hasTheUserPurchasedTickets(_eventId)
    public
    view
    returns (uint)
    {
        return events[_eventId].buyers[msg.sender];

    }
    /*
        Define a function called endSale()
        This function takes one parameter, the event ID
        Only the contract owner can call this function
        TODO:
            - close event sales
            - transfer the balance from those event sales to the contract owner
            - emit the appropriate event
    */
    function endSale(uint _eventId) 
    isOwner()
    public
    returns(bool){
        events[_eventId].isOpen = false;
        uint balance = events[_eventId].sales * PRICE_TICKET;
        msg.sender.transfer(balance);
        emit LogEndSale(msg.sender, balance, _eventId);
        return true;
    }

}
