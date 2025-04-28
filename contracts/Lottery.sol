// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Lottery {
    address public owner;
    address[] public players;
    mapping(address => bool) public hasEntered;
    uint public ticketPrice;
    uint public roundEndTime;
    uint public feePercent = 5;

    constructor() {
        owner = msg.sender;
        ticketPrice = 5 ether; // 5 Quai (Quai decimals are 18 like ETH)
        roundEndTime = block.timestamp + 7 days;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function buyTicket() external payable {
        require(block.timestamp < roundEndTime, "Round has ended");
        require(msg.value == ticketPrice, "Incorrect ticket price");
        require(!hasEntered[msg.sender], "You have already bought a ticket");

        players.push(msg.sender);
        hasEntered[msg.sender] = true;
    }

    function pickWinners() external onlyOwner {
        require(block.timestamp >= roundEndTime, "Round not yet ended");
        require(players.length >= 1, "Not enough players");

        uint balance = address(this).balance;
        uint fee = (balance * feePercent) / 100;
        uint prizePool = balance - fee;

        payable(owner).transfer(fee);

        uint256[10] memory prizePercents = [
            uint256(30),
            uint256(20),
            uint256(15),
            uint256(10),
            uint256(7),
            uint256(5),
            uint256(4),
            uint256(3),
            uint256(3),
            uint256(3)
        ];


        address[] memory winners = selectWinners();

        for (uint i = 0; i < winners.length; i++) {
            uint prize = (prizePool * prizePercents[i]) / 100;
            payable(winners[i]).transfer(prize);
        }

        resetLottery();
    }

    function selectWinners() private view returns (address[] memory) {
        uint winnersCount = players.length < 10 ? players.length : 10;
        address[] memory winners = new address[](winnersCount);
        address[] memory tempPlayers = players;

        for (uint i = 0; i < winnersCount; i++) {
            uint randIndex = random(i) % tempPlayers.length;
            winners[i] = tempPlayers[randIndex];

            // Remove the selected winner from tempPlayers array
            tempPlayers[randIndex] = tempPlayers[tempPlayers.length - 1];
            assembly { mstore(tempPlayers, sub(mload(tempPlayers), 1)) }
        }

        return winners;
    }

    function random(uint salt) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao, players, salt)));
    }

    function resetLottery() private {
        for (uint i = 0; i < players.length; i++) {
            hasEntered[players[i]] = false;
        }
        delete players;
        roundEndTime = block.timestamp + 7 days;
    }

    function getPlayers() external view returns (address[] memory) {
        return players;
    }

    function getTimeLeft() external view returns (uint) {
        if (block.timestamp >= roundEndTime) return 0;
        return roundEndTime - block.timestamp;
    }
}