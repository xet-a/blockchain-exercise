// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

import "./token.sol";

contract Voting {
    Token public tokenContract;
    uint256 public tokenPrice;
    uint256 public tokenSold;
    address public owner;
    bool public votingActive; // 투표 진행 여부

    // 입후보자, 득표수 structure
    mapping(string => uint256) public nameToVoteCount; // 이름 - 득표수
    mapping(address => uint256) public voteRight; // 주소 - 투표권수

    event Sell(address indexed _buyer, uint256 indexed _amount);
    event Vote(address indexed _voter, string indexed _candidateName);
    event CandidateRegistered(string _name);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor(Token _tokenContract, uint256 _tokenPrice) public {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
        votingActive = true;
    }

    // 토큰 구매
    function buyToken(uint256 _numberOfTokens) public payable {
        // 투표 진행 중
        require(votingActive);
        // value 값과 (구매할 토큰 수 * 토큰 가격) 값 동일
        require(msg.value == _numberOfTokens * tokenPrice * 1 ether);
        // Voting contract의 토큰 잔액이 구매할 토큰 수보다 크거나 같아야 함
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);

        tokenSold += _numberOfTokens;
        emit Sell(msg.sender, _numberOfTokens);
        
        // 구매자(msg.sender)에게 토큰 전송
        require(tokenContract.transfer(msg.sender, _numberOfTokens));
    }

    // 투표권 구매
    function buyVoteRight() public payable {
        // 투표 진행 중
        require(votingActive);
        // 토큰 1개로 투표권 1개 구입 가능
        require(tokenContract.balanceOf(msg.sender) >= 1);

        // 구매자가 Voting 스마트 컨트랙트에게 토큰을 전송할 수 있도록 미리 승인
        // require(tokenContract.approve(address(this), 1));
        // 구매자의 토큰 1개를 Voting contract로 전송
        // require(tokenContract.transferFrom(msg.sender, address(this), 1));
        // require(tokenContract.transfer(address(this), 1));

        // 토큰 파기 후 컨트랙트 토큰에 1개 추가하는 방식으로 구현
        require(tokenContract.burn(msg.sender, 1));
        require(tokenContract.mint(address(this), 1));

        // 구매자의 투표권 수 1 증가
        voteRight[msg.sender] += 1;
    }

    // 후보자 등록
    function registerCandidate(string memory _name) public {
        require(nameToVoteCount[_name] == 0);

        // 후보자 등록
        nameToVoteCount[_name] = 0;
        emit CandidateRegistered(_name);
    }

    // 후보자에게 투표 - 투표권 1개 소모
    function vote(string memory _candidateName) public {
        require(votingActive);
        // 구매자에게 투표권이 있는지 확인
        require(voteRight[msg.sender] >= 1);

        // 후보자의 득표수 1 증가 및 투표권 1개 소모
        nameToVoteCount[_candidateName] += 1;
        voteRight[msg.sender] -= 1;

        emit Vote(msg.sender, _candidateName);
    }

    // 투표권 양도
    function transferVotes(address _to, uint256 _numberOfVotes) public {
        require(voteRight[msg.sender] >= _numberOfVotes);

        voteRight[msg.sender] -= _numberOfVotes;
        voteRight[_to] += _numberOfVotes;
    }

    // 토큰 가격 변경
    function changeTokenPrice(uint256 _newPrice) public onlyOwner {
        tokenPrice = _newPrice;
    }

    // 투표 종료
    function endVoting() public onlyOwner {
        votingActive = false;
        // 남은 토큰 소유자에게 전송
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        // 잔여 ETH 소유자에게 전송
        msg.sender.transfer(address(this).balance);
    }
}