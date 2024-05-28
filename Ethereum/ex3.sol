pragma solidity ^0.6.4;

contract testContract {
    address owner;
    event fundMoved(address _to);
    modifier onlyowner { require(msg.sender == owner); _; }
    address[] _giver;
    uint[] _values;

    constructor () public {
        owner = msg.sender;
    }

    function donate() public payable {
        addGiver(msg.value);
    }

    function moveFund(address payable _to) onlyowner public {
        uint balance = address(this).balance;
        if(0 <= balance) {
            if (_to.send(balance)) {
                emit fundMoved(_to);
            } else {
                revert();
            }
        } else {
            revert();
        }
    }

    function addGiver(uint _amount) internal {
        _giver.push(msg.sender);
        _values.push(_amount);
    }
}