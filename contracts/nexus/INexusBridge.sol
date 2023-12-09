//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface INexusBridge {
    struct Balance {
        uint256 Deposits;
        uint256 Withdrawals;
        uint256 Rewards;
    }
    struct Validator {
        bytes pubKey;
        bytes withdrawalAddress;
        bytes signature;
        bytes32 depositRoot;
    }
    error NotNexus();
    error NotDAO();
    error IncorrectAmount();
    error IncorrectWithdrawalCredentials();
    error StakingLimitExceeding();
    error WrongRewardAmount();

    event Rewards(uint256 amount);

    function depositValidatorNexus(
        Validator[] calldata _validators,
        uint256 stakingLimit,
        uint256 validatorCount
    ) external;

    function updateRewards(uint256 amount, bool slashed,uint256 validatorCount) external;
}
