pragma solidity >=0.4.22 <0.7.0;

contract AutoAuction {
    address payable public beneficiary;
    uint public auctionEndTime;
    uint public biddingTimeExtension = 30;

    address public preHighestBidder;
    address public highestBidder;
    uint public highestBid;

    // 자동 입찰 시스템
    struct AutoBid {
        uint maxBid;
        uint currentBid;
    }
    mapping(address => AutoBid) public autoBids;

    mapping(address => uint) pendingReturns;

    bool ended;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    // 경매 시간 연장
    event AuctionExtended(uint newEndTime);

    constructor(uint _biddingTime, address payable _beneficiary) public {
        beneficiary = _beneficiary;
        auctionEndTime = now + _biddingTime;
    }

    function getRemainingTime() public view returns (uint) {
        if (block.timestamp >= auctionEndTime) {
            return 0; // 경매가 이미 종료된 경우
        } else {
            return auctionEndTime - block.timestamp;
        }
    }

    // 최대 입찰가 매개변수로 받음
    function bid(uint _maxBid) public payable {
        require(now <= auctionEndTime, "Auction already ended.");
        require(msg.value > highestBid, "현재 최고 입찰액보다 큰 금액으로 입찰한 경우 입찰 가능");
        require(msg.sender.balance >= _maxBid, "사용자의 잔액을 초과하는 최대 입찰가는 설정할 수 없음");
        require(_maxBid >= msg.value, "제시한 입찰 가격보다 최대 입찰가가 더 작을 수 없음");

        autoBids[msg.sender] = AutoBid({
            maxBid: _maxBid,
            currentBid: msg.value
        });

        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
            preHighestBidder = highestBidder;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value);

        // 남은 시간 계산 및 연장
        checkAndExtendAuction();
        // 이전 highestBidder의 maxBid 값이 highestBid보다 큰 경우에만 자동 입찰 수행
        if (autoBids[preHighestBidder].maxBid > highestBid) {
            // 자동 입찰 확인 및 highest 갱신
            processAutoBids();
        }
    }

    // 남은 경매 시간 10초 미만인 경우, 경매 시간 30초 연장
    function checkAndExtendAuction() internal {
        if (auctionEndTime - now < 10) {
            auctionEndTime += biddingTimeExtension;
            emit AuctionExtended(auctionEndTime);
        }
    }

    function withdraw() public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            if (!msg.sender.send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() public {
        require(now >= auctionEndTime, "Auction not yet ended.");
        require(!ended, "auctionEnd has already been called.");

        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        beneficiary.transfer(highestBid);
    }

    function processAutoBids() internal {
        // 최대 입찰 가능 가격을 비교해서 (더 작은 값 + 1 ETH)로 highestBid 갱신
        uint preMaxBid = autoBids[preHighestBidder].maxBid;
        uint maxBid = autoBids[highestBidder].maxBid;
        
        if (preMaxBid > maxBid) {
            highestBid = maxBid + 1 ether;
            highestBidder = preHighestBidder;
        } else if (preMaxBid == maxBid) {
            // 서로 같은 경우는 가장 일찍 입찰했던 preHighestBidder로 설정
            highestBid = preMaxBid;
            highestBidder = preHighestBidder;
        } else {
            highestBid = preMaxBid + 1 ether;
        }
        emit HighestBidIncreased(highestBidder, highestBid);
        checkAndExtendAuction();
    }

}
