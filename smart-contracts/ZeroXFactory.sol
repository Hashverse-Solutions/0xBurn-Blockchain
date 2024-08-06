// File: contracts/interfaces/IZeroXFactory.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.8.19;

interface IZeroXFactory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

// File: contracts/interfaces/IZeroXERC20.sol



pragma solidity =0.8.19;

interface IZeroXERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// File: contracts/interfaces/IZeroXPair.sol



pragma solidity =0.8.19;

interface IZeroXPair is IZeroXERC20 {
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(
        address to
    ) external returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

// File: contracts/ZeroXERC20.sol



pragma solidity =0.8.19;

/// @title ZeroXERC20
/// @author Taimoor Malik - Hashverse Solutions
/// @notice A standard ERC20 token with ZeroX's permit functionality
/// @dev This contract is used for the ZeroX Liquidity Pool tokens
contract ZeroXERC20 is IZeroXERC20 {
    string public constant override name = "ZeroX";
    string public constant override symbol = "0xBurn-LP";
    uint8 public constant override decimals = 18;
    uint256 public override totalSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    bytes32 public override DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant override PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public override nonces;

    constructor() payable {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    /// @notice Mints LP tokens to an address to represent underlying assets
    /// @dev This function is used by the ZeroX Router to mint tokens for the Liquidity Pool
    /// @param to The address to mint tokens to
    /// @param value The amount of tokens to mint

    function _mint(address to, uint256 value) internal {
        unchecked {
            totalSupply += value;
            balanceOf[to] += value;
        }
        emit Transfer(address(0), to, value);
    }

    /// @notice Burns LP tokens from an address to claim underlying assets
    /// @dev This function is used by the ZeroX Router to burn tokens from the Liquidity Pool
    /// @param from The address to burn tokens from
    /// @param value The amount of tokens to burn

    function _burn(address from, uint256 value) internal {
        balanceOf[from] -= value;
        totalSupply -= value;
        emit Transfer(from, address(0), value);
    }

    ///@notice Approves a spender to spend a certain amount of tokens on behalf of the owner
    ///@dev This function is used by the user to approve the ZeroX Router to spend LP tokens on behalf of the Liquidity Provider
    ///@param owner The address that owns the tokens
    ///@param spender The address that is approved to spend the tokens
    ///@param value The amount of tokens that the spender is approved to spend

    function _approve(address owner, address spender, uint256 value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    ///@notice Transfers tokens from one address to another
    ///@dev This function is used by the user to transfer LP tokens to another address
    ///@param from The address that owns the tokens
    ///@param to The address that is receiving the tokens

    function _transfer(address from, address to, uint256 value) private {
        balanceOf[from] -= value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }

    ///@notice Approve LP tokens to be spent by another address
    ///@dev This function is used by the user to approve the ZeroX Router to spend LP tokens on behalf of the Liquidity Provider
    ///@param spender The address that is approved to spend the tokens
    ///@param value The amount of tokens that the spender is approved to spend
    function approve(
        address spender,
        uint256 value
    ) external override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    ///@notice Transfers tokens from one address to another
    ///@dev This function is used by the user to transfer LP tokens to another address
    ///@param to The address that is receiving the tokens
    ///@param value The amount of tokens that are being transferred
    function transfer(
        address to,
        uint256 value
    ) external override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    ///@notice Transfers tokens from one address to another
    ///@dev This function is used by the ZeroX Router to transfer LP tokens from the Liquidity Provider to the Liquidity Pool
    ///@param from The address that owns the tokens
    ///@param to The address that is receiving the tokens
    ///@param value The amount of tokens that are being transferred
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= value;
        }
        _transfer(from, to, value);
        return true;
    }

    ///@notice Approve LP tokens to be spent by another address using a signature
    ///@dev This function is used by the user to approve the ZeroX Router to spend LP tokens on behalf of the Liquidity Provider without requiring an on-chain transaction
    ///@param owner The address that owns the tokens
    ///@param spender The address that is approved to spend the tokens
    ///@param value The amount of tokens that the spender is approved to spend
    ///@param deadline The timestamp that the signature expires
    ///@param v The recovery byte of the signature
    ///@param r The first 32 bytes of the signature
    ///@param s The second 32 bytes of the signature

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {
        require(deadline >= block.timestamp, "ZeroX: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner]++,
                        deadline
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "ZeroX: INVALID_SIGNATURE"
        );
        _approve(owner, spender, value);
    }
}

// File: contracts/libraries/Math.sol



pragma solidity =0.8.19;

// a library for performing various math operations

library Math {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        unchecked {
            if (y > 3) {
                z = y;
                uint256 x = y / 2 + 1;
                while (x < z) {
                    z = x;
                    x = (y / x + x) / 2;
                }
            } else if (y != 0) {
                z = 1;
            }
        }
    }
}

// File: contracts/libraries/UQ112x112.sol



pragma solidity =0.8.19;

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    //solhint-disable-next-line state-visibility
    uint224 constant Q112 = 2 ** 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        unchecked {
            z = uint224(y) * Q112; // never overflows
        }
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}

// File: contracts/interfaces/IERC20.sol



pragma solidity =0.8.19;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

// File: contracts/interfaces/IZeroXCallee.sol



pragma solidity =0.8.19;

interface IZeroXCallee {
    function zeroXCall(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}

// File: contracts/ZeroXPair.sol



pragma solidity =0.8.19;

/// @title ZeroXPair - An ERC20 token that represents ownership of a pair of assets
/// @author Taimoor Malik - Hashverse Solutions
/// @notice This contract is used for the ZeroX Liquidity Pool tokens
/// @dev Holds underlying assets in a contract and mints/burns LP tokens to represent ownership of the underlying assets
contract ZeroXPair is IZeroXPair, ZeroXERC20 {
    using UQ112x112 for uint224;

    uint256 public constant override MINIMUM_LIQUIDITY = 10 ** 3;

    address public override factory;
    address public override token0;
    address public override token1;

    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint256 public override price0CumulativeLast;
    uint256 public override price1CumulativeLast;
    uint256 public override kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "ZeroX: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    ///@notice Returns the reserves of the pairs underlying assets
    ///@dev This function is used by the ZeroX Router to get the reserves of the underlying assets
    ///@return _reserve0 The reserve of the first underlying asset
    ///@return _reserve1 The reserve of the second underlying asset
    ///@return _blockTimestampLast The timestamp of the last liquidity event
    function getReserves()
        public
        view
        override
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    ///@notice Transfers tokens from one address to another
    ///@dev An internal function that is used to transfer tokens
    ///@param token The address of the token to transfer
    ///@param to The address to transfer tokens to
    ///@param value The amount of tokens to transfer
    function _safeTransfer(address token, address to, uint256 value) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(IERC20.transfer.selector, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "ZeroX: TRANSFER_FAILED"
        );
    }

    constructor() payable {
        factory = msg.sender;
    }

    // called once by the factory at time of deployment
    ///@notice Initializes the pair with the underlying assets
    ///@dev This function is used by the ZeroX Factory to initialize the pair with the underlying assets
    ///@param _token0 The address of the first underlying asset
    ///@param _token1 The address of the second underlying asset

    function initialize(address _token0, address _token1) external override {
        require(msg.sender == factory, "ZeroX: FORBIDDEN"); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    ///@notice Updates the reserves of the pair
    ///@dev This internal function is used by the mint, burn, and swap functions to update the reserves of the pair
    ///@param balance0 The balance of the first underlying asset
    ///@param balance1 The balance of the second underlying asset
    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {
        require(
            balance0 <= type(uint112).max && balance1 <= type(uint112).max,
            "ZeroX: OVERFLOW"
        );
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        unchecked {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
            if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
                // * never overflows, and + overflow is desired
                price0CumulativeLast +=
                    uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                    timeElapsed;
                price1CumulativeLast +=
                    uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                    timeElapsed;
            }
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    ///@notice Pays the fee to the feeTo address if the fee is on
    ///@dev This internal function is used by the mint and burn functions to pay the fee to the feeTo address if the fee is on
    ///@param _reserve0 The reserve of the first underlying asset
    ///@param _reserve1 The reserve of the second underlying asset
    function _mintFee(
        uint112 _reserve0,
        uint112 _reserve1
    ) private returns (bool feeOn) {
        address feeTo = IZeroXFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(_reserve0) * _reserve1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply * (rootK - rootKLast);
                    uint256 denominator = rootK * 5 + rootKLast;
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    ///@notice Mints LP tokens to an address to represent underlying assets
    ///@dev This function is used by the ZeroX Router to mint tokens for the Liquidity Pool
    ///@param to The address to mint tokens to
    ///@return liquidity The amount of LP tokens minted

    function mint(
        address to
    ) external override lock returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(
                (amount0 * _totalSupply) / _reserve0,
                (amount1 * _totalSupply) / _reserve1
            );
        }
        require(liquidity > 0, "ZeroX: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0) * reserve1; // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    ///@notice Burns LP tokens from an address to claim underlying assets
    ///@dev This function is used by the ZeroX Router to burn tokens from the Liquidity Pool
    ///@param to The address to burn tokens from
    ///@return amount0 The amount of the first underlying asset claimed
    ///@return amount1 The amount of the second underlying asset claimed
    function burn(
        address to
    ) external override lock returns (uint256 amount0, uint256 amount1) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = (liquidity * balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = (liquidity * balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(
            amount0 > 0 && amount1 > 0,
            "ZeroX: INSUFFICIENT_LIQUIDITY_BURNED"
        );
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0) * reserve1; // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    ///@notice Swaps one underlying asset for another
    ///@dev This function is used by the ZeroX Router to swap one underlying asset for another
    ///@param amount0Out The amount of the first underlying asset to swap out
    ///@param amount1Out The amount of the second underlying asset to swap out
    ///@param to The address to send the swapped tokens to
    ///@param data The data to send to the recipient
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external override lock {
        require(
            amount0Out > 0 || amount1Out > 0,
            "ZeroX: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "ZeroX: INSUFFICIENT_LIQUIDITY"
        );

        uint256 balance0;
        uint256 balance1;
        {
            // scope for _token{0,1}, avoids stack too deep errors
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "ZeroX: INVALID_TO");
            uint256 amount0OutBurn = amount0Out / 100; // For 1% Burn
            uint256 amount0OutSwap = amount0Out - amount0OutBurn; // For optimistically transfer tokens
            if (amount0Out > 0) _safeTransfer(_token0, address(0), amount0OutBurn); // optimistically transfer tokens
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0OutSwap); // optimistically transfer tokens
            // if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
            if (data.length > 0)
                IZeroXCallee(to).zeroXCall(
                    msg.sender,
                    amount0Out,
                    amount1Out,
                    data
                );
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint256 amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0;
        require(
            amount0In > 0 || amount1In > 0,
            "ZeroX: INSUFFICIENT_INPUT_AMOUNT"
        );
        {
            // scope for reserve{0,1}Adjusted, avoids stack too deep errors
            uint256 balance0Adjusted = balance0 * 1000 - amount0In * 3;
            uint256 balance1Adjusted = balance1 * 1000 - amount1In * 3;
            unchecked {
                require(
                    balance0Adjusted * balance1Adjusted >=
                        uint256(_reserve0) * _reserve1 * 1000 ** 2,
                    "ZeroX: K"
                );
            }
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // force balances to match reserves
    ///@notice Skims the excess tokens from the pair
    ///@dev This function is used by the ZeroX Router to skim the excess tokens from the pair
    ///@param to The address to send the excess tokens to

    function skim(address to) external override lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(
            _token0,
            to,
            IERC20(_token0).balanceOf(address(this)) - reserve0
        );
        _safeTransfer(
            _token1,
            to,
            IERC20(_token1).balanceOf(address(this)) - reserve1
        );
    }

    // force reserves to match balances
    ///@notice Syncs the reserves of the pair
    ///@dev This function is used by the ZeroX Router to sync the reserves of the pair
    function sync() external override lock {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0,
            reserve1
        );
    }
}

// File: contracts/ZeroXFactory.sol



pragma solidity =0.8.19;

/// @title ZeroXFactory
/// @notice Factory contract for creating ZeroX Liquidity Pairs
/// @dev This contract is used to deploy new ZeroX Liquidity Pairs and track all pairs that have been deployed
contract ZeroXFactory is IZeroXFactory {
    bytes32 public constant PAIR_HASH =
        keccak256(type(ZeroXPair).creationCode);

    address public override feeTo;
    address public override feeToSetter;

    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    constructor(address _feeToSetter) payable {
        feeToSetter = _feeToSetter;
    }

    ///@notice Returns the number of ZeroX Liquidity Pairs that have been deployed
    ///@return Gets the length of the allPairs array to determine the number of deployed pairs
    function allPairsLength() external view override returns (uint256) {
        return allPairs.length;
    }

    ///@notice Creates a new ZeroX Liquidity Pair
    ///@dev This function calls the ZeroXPair contract with the CREATE2 opcode to deploy a new pair
    ///@param tokenA The first token in the pair
    ///@param tokenB The second token in the pair
    ///@return pair The address of the newly deployed pair
    function createPair(
        address tokenA,
        address tokenB
    ) external override returns (address pair) {
        require(tokenA != tokenB, "ZeroX: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "ZeroX: ZERO_ADDRESS");
        require(
            getPair[token0][token1] == address(0),
            "ZeroX: PAIR_EXISTS"
        ); // single check is sufficient

        pair = address(
            new ZeroXPair{
                salt: keccak256(abi.encodePacked(token0, token1))
            }()
        );
        IZeroXPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    ///@notice Sets the feeTo address for the factory -  Used to collect fees from the factory when pairs are created
    ///@dev This function can only be called by the feeToSetter address
    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter, "ZeroX: FORBIDDEN");
        feeTo = _feeTo;
    }

    ///@notice Sets the feeToSetter address for the factory -  Used to set the feeToSetter address
    ///@dev This function can only be called by the feeToSetter address -  Transfers ownership of the factory to a new address
    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, "ZeroX: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}
