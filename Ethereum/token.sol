// SPDX-License-Identifier: MIT
pragma solidity ^0.6.4;

contract Token {
    string public name = "Test ERC20 Token";
    string public symbol = "TET";

    uint256 public totalSupply;
    uint8 public decimals;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 value);
    event Mint(address indexed _to, uint256 _value);
    event Burn(address indexed _from, uint256 _value);
    
    mapping (address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(uint256 _initSupply) public {
        balanceOf[msg.sender] = _initSupply;
        totalSupply = _initSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // event LogMessage(address sender, address contractAddress);
    // 토큰 소유자가 직접 다른 계정으로 토큰 전송
    function transfer(address _to, uint256 _value) public returns (bool success) {
        // emit LogMessage(msg.sender, address(this));
        require(balanceOf[msg.sender] >= _value);
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // approve로 승인받은 토큰을 전송
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    // 토큰 소유자가 다른 계정에게 자신의 토큰을 사용할 수 있는 권한 부여
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // 토큰 추가 발행
    function mint(address _to, uint256 _value) public returns (bool success) {
        totalSupply += _value;
        balanceOf[_to] += _value;

        emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    // 토큰 파기
    function burn(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);

        balanceOf[_from] -= _value;
        totalSupply -= _value;

        emit Burn(_from, _value);
        emit Transfer(_from, address(0), _value);
        return true;
    }
}