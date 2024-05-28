pragma solidity ^0.6.4;

contract testContract {
    string public msg1;
    string private msg2;

    address public owner;
    uint256 public counter;

    constructor (string memory _msg1) public {
        msg1 = _msg1;
        owner = msg.sender;
        counter = 0;
    }

    function setMsg2(string memory _msg2) public {
        if(owner != msg.sender) {
            revert();
        } else {
            msg2 = _msg2;
        }
    }

    function getMsg2() view public returns(string memory) {
        return msg2;
    }

    function setCounter() public {
        for(uint256 i = 0; i < 3; i ++) {
            counter ++;
        }
    }
}