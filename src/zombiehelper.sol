pragma solidity ^0.4.0;

import "./zombiefeeding.sol";

contract zombiehelper {
    modifier aboveLevel(uint _level, uint _zombieId) {
        require(zombies[_zombieId].level >= _level);
        _;
    }
}
