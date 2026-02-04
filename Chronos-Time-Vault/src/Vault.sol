// SPDX-License-Identifier: MIT

import {IChronosToken} from "src/IChronosToken.sol";
import {Owner} from "src/Owner.sol";

pragma solidity ^0.8.0;

struct User {
    uint256 amount;
    uint256 startTime;
    uint256 lockPeriod;
}

contract Vault is Owner {
    address private tokenContractAddress;
    mapping(address => User) private addressToEth;

    uint rate;
    uint256 totalEther;

    event stakeEther(address indexed userAddress, uint256 amount);
    event withdrawEther(address indexed userAddress, uint256 amount);

    constructor(address _tokenContractAddress) Owner(msg.sender) {
        tokenContractAddress = _tokenContractAddress;
        rate = 1;
        totalEther = 0;
    }

    function changeRate(uint256 _newRate) public onlyOwner returns (bool) {
        rate = _newRate;
        return true;
    }

    function withdrawEthOwner(uint _amount) public onlyOwner returns (bool) {
        require(_amount <= totalEther, "Insufficient Ethers");

        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Error while Transfering the Ether to Contract Owner");

        return true;
    }

    function sendEtherOwner() public payable onlyOwner returns (bool) {
        totalEther += msg.value;
        return true;
    }

    function stake() public payable returns (bool) {
        require(msg.value > 0, "Send Some Eth Please");

        if (addressToEth[msg.sender].amount > 0) {
            uint256 reward = calculateReward(
                addressToEth[msg.sender].amount,
                addressToEth[msg.sender].startTime
            );

            addressToEth[msg.sender].amount += msg.value;
            addressToEth[msg.sender].startTime = block.timestamp;
            addressToEth[msg.sender].lockPeriod = block.timestamp + 30 days;
            totalEther += msg.value;

            IChronosToken(tokenContractAddress).mintTo(msg.sender, reward);

            emit stakeEther(msg.sender, msg.value);

            return true;
        }

        addressToEth[msg.sender] = User({
            amount: msg.value,
            startTime: block.timestamp,
            lockPeriod: block.timestamp + 30 days
        });
        totalEther += msg.value;

        emit stakeEther(msg.sender, msg.value);

        return true;
    }

    function withdraw() public returns (bool) {
        require(
            addressToEth[msg.sender].amount > 0,
            "you haven't staked anything yet"
        );

        uint256 lockPeriod = addressToEth[msg.sender].lockPeriod;

        if (block.timestamp < lockPeriod) {
            uint256 amountToBeReturned = (addressToEth[msg.sender].amount *
                7 +
                10 -
                1) / 10;
            delete addressToEth[msg.sender];
            totalEther -= amountToBeReturned;

            (bool success, ) = payable(msg.sender).call{
                value: amountToBeReturned
            }("");
            require(success, "Failed To WithDraw Your Remaining Amount");

            emit withdrawEther(msg.sender, amountToBeReturned);
            return true;
        }

        uint256 reward = calculateReward(
            addressToEth[msg.sender].amount,
            addressToEth[msg.sender].startTime
        );
        uint256 amount = addressToEth[msg.sender].amount;
        delete addressToEth[msg.sender];
        totalEther -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Failed To Withdraw Entire Amount");
        IChronosToken(tokenContractAddress).mintTo(msg.sender, reward);

        emit withdrawEther(msg.sender, amount);

        return true;
    }

    function calculateReward(
        uint256 _amountStaked,
        uint startTime
    ) internal view returns (uint256) {
        if (startTime > block.timestamp) return 0;

        uint256 baseDaysSecond = 30 days;
        uint256 remainingTime = block.timestamp - startTime;

        uint256 amountIn9Decimal = (_amountStaked + 1e9 - 1) / 1e9;

        uint256 numerator = remainingTime * amountIn9Decimal * rate;
        uint256 denominator = baseDaysSecond;

        uint256 reward = (numerator + denominator - 1) / denominator;

        return reward;
    }
}
