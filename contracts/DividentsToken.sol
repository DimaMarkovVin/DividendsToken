pragma solidity ^0.4.18;

import "./ERC20Interface.sol";
import "./lib/itMaps.sol";
import "./lib/SafeMath.sol";


contract Tokenv1 is ERC20Interface {

    using itMaps for itMaps.itMapAddressUint;
    using SafeMath for uint256;

    string public constant name = "Divident Token";
    string public constant symbol = "DET";
    uint8 public constant decimals = 3;

    uint256 _totalSupply = 1000000000;

    address public owner;

    uint256 public tokenPrice;

    uint256 public constant amountOfEthereum = this.balance; 

    mapping (address => mapping (address => uint256)) allowed;

    itMaps.itMapAddressUint tokensBalances;
    itMaps.itMapAddressUint ethereumBalances;

    function Tokenv1() public {
        owner = msg.sender;
        tokensBalances.insert(owner,_totalSupply);
    }


    function totalSupply() public constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
        return totalSupply;
    }

    function balanceOf(address _owner) public constant returns (uint256 balance) {
        balance = tokensBalances.get(_owner);
        return balance;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if(tokensBalances.get(msg.sender) >= _value && _value > 0 && tokensBalances.get(_to) + _value >= tokensBalances.get(_to)) { 
            tokensBalances.insert(_to, tokensBalances.get(_to) + _value);
            tokensBalances.insert(msg.sender,(tokensBalances.get(msg.sender) - _value));
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if(tokensBalances.get(msg.sender) >= _value &&
            tokensBalances.get(_to) + _value >= tokensBalances.get(_to) && 
            allowed[_from][msg.sender] >= _value) { 
                tokensBalances.insert(_from, tokensBalances.get(_from)-_value);
                allowed[_from][msg.sender]-=_value;
                tokensBalances.insert(_to, tokensBalances.get(_to)+_value);
                Transfer(_from,_to,_value);
                return true;
        }
        else {
            return false;
        }
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    function() payable {
        getDividents();
    }

    function getDividents() private {
        uint256 value;
        address key;
        
        tokenPrice = amountOfEthereum.div(_totalSupply);

        for(uint i = 0; i < tokensBalances.size(); i++){
            value = tokensBalances.getValueByIndex(i);
            key = tokensBalances.getKeyByIndex(i);

            ethereumBalances.insert(key, value.mul(tokenPrice));

            key.transfer(value.mul(tokenPrice));
        }
    }

    function balanceOfETH(address _owner) public constant returns (uint256 balance) {
        balance = ethereumBalances.get(_owner);
        return balance;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}