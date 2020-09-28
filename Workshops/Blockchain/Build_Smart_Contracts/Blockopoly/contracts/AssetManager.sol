pragma solidity >=0.5.0 <0.7.0;
 
contract AssetManager {
    address public manager;
 
    struct Asset {
        address owner;
        string name;
        uint price;
        bool exists;
    }
 
    mapping (uint => Asset) private assets;
 
    event AssetAdded(address sender, string name);
    event AssetTransfered(address sender, address from, address to, string name);

    constructor() public {
        manager = msg.sender;
    }
 
    function addAsset(string memory _name, uint _price, address  _owner) public {
        require(msg.sender == manager, "Only the Asset Manager can add assets");
        uint assetId = uint(keccak256(abi.encodePacked(_name)));
        require(!assets[assetId].exists, "Asset name already added");

        Asset memory a = Asset({
            owner: _owner,
            name: _name,
            price: _price,
            exists: true
          }
        );
        assets[assetId] = a;

        emit AssetAdded(msg.sender, _name);
    }
 
    function getOwner(string memory _name) public view returns (address) {
        uint assetId = uint(keccak256(abi.encodePacked(_name)));
        Asset memory a = assets[assetId];
        require(a.exists, "Asset does not exist");
        return a.owner;
    }
 
    function transferAsset(address from, address to, string memory _name) public {
        require(msg.sender == manager, "Only the AssetManager can transfer assets");
        uint assetId = uint(keccak256(abi.encodePacked(_name)));
        Asset memory a = assets[assetId];
 
        require(a.exists, "Asset must exist");
        require(a.owner == from, "Asset must be owned by from address");
 
        a.owner = to;
        assets[assetId] = a;
 
        emit AssetTransfered(msg.sender, from, to, _name);
    }
}