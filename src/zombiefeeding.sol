// Define solidity version.
pragma solidity >=0.5.0 <0.6.0;

// Imports.
import "./zombiefactory.sol";

contract KittyInterface {
    function getKitty(uint256 _id) external view returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 genes
    );
}

// Define contract.
contract ZombieFeeding is ZombieFactory {

    KittyInterface kittyContract;

    // Init interface to cryptoKitties contract.
    function setKittyContractAddress(address _address) external onlyOwner {
        kittyContract = KittyInterface(_address);
    }

    // This is the function used to set the cooldown for a zombie.
    function _triggerCooldown(Zombie storage _zombie) internal {
        _zombie.readyTime = uint32(now + cooldownTime);
    }

    // This is the function used to evaluate if a zombie is ready to feed again.
    function _isReady(Zombie storage _zombie) internal view returns (bool) {
        return (_zombie.readyTime <= now);
    }

    // This is the function used to make a zombie eat and evolve. Note : they eat cryptoKitties.
    function feedAndMultiply(uint256 _zombieId, uint256 _targetDna, string memory _species) internal {
        require(msg.sender == zombieToOwner[_zombieId]);
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie));
        _targetDna = _targetDna % dnaModulus;
        uint256 newDna = (myZombie.dna + _targetDna) / 2;
        if (keccak256(abi.encodePacked(_species)) == keccak256(abi.encodePacked("kitty"))) {
            newDna = newDna - newDna % 100 + 99;
        }
        _createZombie("NoName", newDna);
        _triggerCooldown(myZombie);
    }

    function feedOnKitty(uint256 _zombieId, uint256 _kittyId) public {
        uint256 kittyDna;
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }
}
