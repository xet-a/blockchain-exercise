pragma solidity >=0.4.22 <0.7.0;

contract SimpleAuction {
    // Parameters of the auction. Times are either
    // absolute unix timestamps (seconds since 1970-01-01)
    // or time periods in seconds.
    address payable public beneficiary;
    uint public auctionEndTime;

    // 가장 높은 입찰 금액 제시자 및 금액
    // Current state of the auction.
    address public highestBidder;
    uint public highestBid;

    // Allowed withdrawals of previous bids
    mapping(address => uint) pendingReturns;

    // Set to true at the end, disallows any change.
    // By default initialized to `false`.
    bool ended;

    // Events that will be emitted on changes.
    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

 
    constructor(
        uint _biddingTime,
        address payable _beneficiary
    ) public {
        beneficiary = _beneficiary;
        auctionEndTime = now + _biddingTime;
    }

 
    function bid() public payable {
        
       ///slide #7
       ///write your code for bid function
       require(
            now <= auctionEndTime,
            "Auction already ended."
       );

       require(
            msg.value > highestBid,
            "There already is a higher bid."
        );

        // save return bid
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        // update highest bid and bidder
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    /// Withdraw a bid that was overbid.
    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
         
            ///slide #8
            ///write your code for withdraw function
            pendingReturns[msg.sender] = 0;

            if(!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
            
        }
        return true;
    }

    /// End the auction and send the highest bid
    /// to the beneficiary.
    function auctionEnd() public {
   
        // 1. checking conditions
        // 2. performing actions (potentially changing conditions)
        // 3. interacting with other contracts
 

        // 1. Conditions
        // 경매 시간 전 or 경매가 종료된 경우
        require(now >= auctionEndTime, "Auction not yet ended.");
        require(!ended, "auctionEnd has already been called.");


        // 2. Effects
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // 3. Interaction
        // 최종 낙찰가 beneficiary에 전송
        beneficiary.transfer(highestBid);

    }
}