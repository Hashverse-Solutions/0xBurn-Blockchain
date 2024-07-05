// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;


// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mintERC20Token(address to, uint256 amount) external;
}

// File: contracts/SeedRound.sol

contract SeedRound {
    uint256 public minimumAmount;
    address payable payableRecipient;
    address public xrcToken;
    address public owner;

    event Buy(address indexed beneficiary, uint256 indexed amountInvested,uint256 _receive0xBurn,string indexed token);

    constructor(
        uint256 _minimumAmount,
        address payable _payableRecipient,
        address payable _xrcToken
    ) {
        minimumAmount = _minimumAmount;
        payableRecipient = payable(_payableRecipient);
        xrcToken = _xrcToken;
    }

    event Received(address, uint256);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /// @notice This is a public buyUsingUSDT function, this function requires USDT transfer to book OxBurn tokens and emits event to store data on chain
    /// @param _to This parameter indicates address which will receive OxBurn tokens
    /// @param _tokenAmount This parameter indicates value of USDT to be submitted
    /// @return bool This parameter indicates wether transaction was successfull/un-successfull
    function buyUsingUSDT(
        address _to,
        uint256 _tokenAmount,
        uint256 _receive0xBurn
    ) public payable returns (bool) {
        require(_tokenAmount >= minimumAmount, "SeedRound: minimum 1000 USDT or equivalent Arbitrum investment is required to participate in seed round");

        IERC20(xrcToken).transferFrom(
            msg.sender,
            payableRecipient,
            _tokenAmount
        );

        emit Buy(_to, _tokenAmount, _receive0xBurn, "USDT");
        return true;
    }

    /// @notice This is a public buyUsingArbitrum function, this function requires Arbitrum transfer to book OxBurn tokens and emits event to store data on chain
    /// @param _to This parameter indicates address which will receive OxBurn tokens
    /// @return bool This parameter indicates wether transaction was successfull/un-successfull
    function buyUsingArbitrum(
        address _to,
        uint256 _receive0xBurn
    ) public payable returns (bool) {
        // require(msg.value >= minimumAmount, "SeedRound: minimum 1000 USDT or equivalent Arbitrum investment is required to participate in seed round");

        payableRecipient.transfer(msg.value);
        emit Buy(_to, msg.value, _receive0xBurn, "Arbitrum");
        return true;
    }

    function updatePayableRecipient(
        address _payableRecipient
    ) public {
        require(msg.sender == owner,"only owner can change recipient");
        payableRecipient = payable(_payableRecipient);        
    }
    
}