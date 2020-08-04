pragma solidity >=0.5.0 <0.7.0;
 
import "./Bank.sol";
import "./AssetManager.sol";
 
contract Blockopoly {
    address public banker;
    Bank public bank;
    AssetManager public assetManager;

    struct  Player {
        address addr;
        string name;
    }
    Player[] public players;
    mapping(string => bool) public names;
    mapping(address => Player) public addrPlayerMapping;

    bool public started;
    uint256 private endTime;
 
    event GameStarted();
    event PlayerJoined(address player, string name);

    constructor() public {
        banker = msg.sender;
        bank = new Bank();
        bank.mint(banker, 100000);
        
        assetManager = new AssetManager();
        publishProperties();
    }
 
    function publishProperties() private {
        assetManager.addAsset("Redmond Reactor", 100, banker);
        assetManager.addAsset("Seattle Reactor", 100, banker);
        assetManager.addAsset("San Francisco Reactor", 100, banker);
        assetManager.addAsset("New York Reactor", 100, banker);
        assetManager.addAsset("Toronto Reactor", 100, banker);
        assetManager.addAsset("London Reactor", 100, banker);
        assetManager.addAsset("Sao Paulo Reactor", 100, banker);
        assetManager.addAsset("Tel Aviv Reactor", 100, banker);
        assetManager.addAsset("Stockholm Reactor", 100, banker);
        assetManager.addAsset("Abu Dhabi Reactor", 100, banker);
        assetManager.addAsset("Sydney Reactor", 100, banker);
        assetManager.addAsset("Shanghai Reactor", 100, banker);
        assetManager.addAsset("Bangalore Reactor", 100, banker);
    }
 
    function startGame() public {
        require(msg.sender == banker, "Only the Banker can start the game");
        require(!started, "Game already started");
 
        uint length = players.length;
        require(length >= 2, "Need at least two players");
 
        for(uint i = 0; i < length; i++) {
            Player memory p = players[i];
            bank.mint(p.addr, 1000);
        }
 
        started = true;
        endTime = now + 15 minutes;
        emit GameStarted();
    }

    function joinGame(string memory _name) public {
        require(players.length < 6, "Game is full");
        require(!names[_name], "Name is already taken");
 
        Player memory p = Player({
            addr: msg.sender,
            name: _name
          }
        );
        players.push(p);
        names[_name] = true;
        addrPlayerMapping[msg.sender] = p;
 
        emit PlayerJoined(msg.sender, _name);
    }
 
    function buyProperty(string memory _name) public {
        require(started, "Game not started");
        require(now <= endTime, "Game over");

        address owner = assetManager.getOwner(_name);
        uint price = 100;
 
        require(owner != msg.sender, "Player can't already own the property");
        require(bank.getBalance(msg.sender) >= price, "Insuficcient funds");
 
        bank.sendMoney(owner, msg.sender, price);
        assetManager.transferAsset(owner, msg.sender, _name);
    }
    
    function getWinner() public view returns (string memory winner) {
        require(started, "Game not started");
        require(now > endTime, "Game not ended");

        uint winnerIndex;
        uint greaterBalance = 0;
        uint auxBalance = 0;
        
        for (uint i = 0; i <  players.length; i++) {
            auxBalance = bank.getBalance(players[i].addr);
            if (auxBalance > greaterBalance) {
                winnerIndex = i;
                greaterBalance = auxBalance;
            }
        }
        return players[winnerIndex].name;
    }
}