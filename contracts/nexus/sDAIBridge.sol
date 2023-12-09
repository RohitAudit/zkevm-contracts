//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.20;

import {ISavingsDai} from "./ISavingsDai.sol";

interface IERC20{
    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);
}

abstract contract sDAIBridge {

    address public Nexus=0x4b3BF56a59E935C6296E84605e6676202348B98b;
    address public constant sDAI=0xD8134205b0328F5676aaeFb3B2a0DC15f4029d8C;
    address public constant DAO=0x14630e0428B9BbA12896402257fa09035f9F7447;
    address public constant DAI=0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844;
    uint256 public constant BASIS_POINT = 10000;
    uint256 public DAIDeposited;
    uint256 public DAIRedeemed;
    error NotNexus();
    error NotDAO();
    event SavingsStarted(uint256 amount);
    event DAIDepositedEvent(uint256 amount);
    event DAIWithdrawnEvent(uint256 amount);

    modifier onlyNexus(){
        if (msg.sender != Nexus) revert NotNexus();
        _;
    }
    modifier onlyDAO(){
        if (msg.sender != DAO) revert NotDAO();
        _;
    }

    function initiateSavings(uint256 savingLimit) external onlyNexus{
        uint256 amountSave = (savingLimit*IERC20(DAI).balanceOf(address(this)))/BASIS_POINT;
        IERC20(DAI).approve(sDAI, amountSave);
        ISavingsDai(sDAI).deposit(amountSave, address(this));
        DAIDeposited = amountSave;
        emit SavingsStarted(amountSave);
    }

    function changeSavingDAI(uint256 savingLimit) external onlyNexus {
        uint256 daiBalance = IERC20(DAI).balanceOf(address(this));
        uint256 currentSavingLimit = DAIDeposited*BASIS_POINT/(DAIDeposited + daiBalance);
        if (currentSavingLimit > savingLimit){
            uint256 amountRedeem = (currentSavingLimit - savingLimit)*(DAIDeposited + daiBalance)/BASIS_POINT;
            ISavingsDai(sDAI).withdraw(amountRedeem, address(this), address(this));
            DAIDeposited -= amountRedeem;
            emit DAIWithdrawnEvent(amountRedeem);
        }
        if(currentSavingLimit < savingLimit){
            uint256 amountSave = (savingLimit - currentSavingLimit)*(DAIDeposited + daiBalance)/BASIS_POINT;
            IERC20(DAI).approve(sDAI, amountSave);
            ISavingsDai(sDAI).deposit(amountSave, address(this));
            DAIDeposited += amountSave;
            emit DAIDepositedEvent(amountSave);
        }
    }

    function claimRewards() external onlyDAO {
        uint256 rewards = ISavingsDai(sDAI).maxWithdraw(address(this)) - DAIDeposited;
        DAIRedeemed+=rewards;
        ISavingsDai(sDAI).withdraw(rewards, DAO, address(this));
    }
}