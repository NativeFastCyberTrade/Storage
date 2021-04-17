pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";

abstract contract Own is Context {
    address private _owner;

    event OwnTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

       function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Own: caller not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }


    function transferOwn(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Own: new owner zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}