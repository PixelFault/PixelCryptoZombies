// Define solidity version.
pragma solidity >=0.5.0 <0.6.0;

// Imports.
import "./ownable.sol";

// Define contract.
contract ZombieFactory is Ownable {

    // This is the event corresponding to the creation of a new zombie.
    event NewZombie(uint256 zombieId, string name, uint256 dna);

    // This is a zombie dna representation.
    uint256 dnaDigits = 16;
    uint256 dnaModulus = 10 ** dnaDigits;

    // This is a cooldown to avoid a super fast zombie levelup.
    uint cooldownTime = 1 days;

    // This is a zombie object.
    struct Zombie {
        string name;
        uint256 dna;
        uint32 level;
        uint32 readyTime;
    }

    // This is a list of zombies.
    Zombie[] public zombies;

    // We create a mapping to map a zombie to its owner.
    mapping (uint256 => address) public zombieToOwner;
    // We create a mapping to map the number of zombies owned by one address.
    mapping (address => uint256) ownerZombieCount;

    // This is the function used to add a zombie into the zombie list.
    function _createZombie(string memory _name, uint256 _dna) internal {
        uint256 id = zombies.push(Zombie(_name, _dna, 1, uint32(now + cooldownTime))) - 1;
        zombieToOwner[id] = msg.sender;
        ownerZombieCount[msg.sender]++;
        emit NewZombie(id, _name, _dna);
    }

    // This is the function used to generate a new dna randomly.
    function _generateRandomDna(string memory _str) private view returns (uint256) {
        uint256 rand = uint256(keccak256(abi.encodePacked(_str)));
        return rand % dnaModulus;
    }

    // This is the function used to create a new random zombie.
    function createRandomZombie(string memory _name) public {
        require(ownerZombieCount[msg.sender] == 0);
        uint256 randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }
}