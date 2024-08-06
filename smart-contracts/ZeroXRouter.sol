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

// File: contracts/interfaces/IZeroXRouter01.sol



pragma solidity =0.8.19;

//solhint-disable func-name-mixedcase

interface IZeroXRouter01 {
    function factory() external view returns (address);

    function WETH() external view returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}

// File: contracts/interfaces/IZeroXRouter.sol



pragma solidity =0.8.19;

interface IZeroXRouter is IZeroXRouter01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
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

// File: contracts/interfaces/IWETH.sol



pragma solidity =0.8.19;

interface IWETH {
    function deposit() external payable;

    function transfer(address to, uint256 value) external returns (bool);

    function withdraw(uint256) external;
}

// File: contracts/libraries/TransferHelper.sol



pragma solidity =0.8.19;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
/// @title TransferHelper
/// @author Taimoor Malik - Hashverse Solutions
/// @notice A library that provides safe transfer methods for ERC20 tokens and ETH
/// @dev Has protections against transfer methods that do not return a bool
library TransferHelper {
    function safeApprove(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeApprove: approve failed"
        );
    }

    function safeTransfer(address token, address to, uint256 value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::safeTransfer: transfer failed"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "TransferHelper::transferFrom: transferFrom failed"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(
            success,
            "TransferHelper::safeTransferETH: ETH transfer failed"
        );
    }
}

// File: contracts/libraries/ZeroXLibrary.sol



pragma solidity =0.8.19;

//solhint-disable reason-string

library ZeroXLibrary {
    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(
        address tokenA,
        address tokenB
    ) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "ZeroXLibrary: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "ZeroXLibrary: ZERO_ADDRESS");
    }

    // calculates the CREATE2 address for a pair without making any external calls
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pair = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            factory,
                            keccak256(abi.encodePacked(token0, token1)),
                            hex"2ee1f95e9d42ed15ddfe11c9e46d063bada351e03bd86ac7b7e527476ad74f19" // init code hash
                        )
                    )
                )
            )
        );
    }

    // fetches and sorts the reserves for a pair
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IZeroXPair(
            pairFor(factory, tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "ZeroXLibrary: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "ZeroXLibrary: INSUFFICIENT_LIQUIDITY"
        );
        unchecked {
            amountB = (amountA * reserveB) / reserveA;
        }
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "ZeroXLibrary: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "ZeroXLibrary: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        unchecked {
            amountOut = numerator / denominator;
        }
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(
            amountOut > 0,
            "ZeroXLibrary: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        require(
            reserveIn > 0 && reserveOut > 0,
            "ZeroXLibrary: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;
        unchecked {
            amountIn = (numerator / denominator) + 1;
        }
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "ZeroXLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; ) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
            unchecked {
                ++i;
            }
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "ZeroXLibrary: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; ) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
            unchecked {
                --i;
            }
        }
    }
}

// File: contracts/ZeroXRouter.sol



pragma solidity =0.8.19;

/// @title ZeroXRouter
/// @author Taimoor Malik - Hashverse Solutions
/// @notice Router contract for swapping tokens and adding/removing liquidity
/// @dev This contract is used to swap tokens and add/remove liquidity from the ZeroX Liquidity Pools
contract ZeroXRouter is IZeroXRouter {
    //solhint-disable-next-line immutable-vars-naming
    address public immutable override factory;
    address public immutable override WETH;

    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "ZeroXRouter: EXPIRED");
        _;
    }

    constructor(address _factory, address _WETH) payable {
        factory = _factory;
        WETH = _WETH;
    }

    receive() external payable {
        assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
    }

    // **** ADD LIQUIDITY ****
    ///@notice Adds liquidity to a pair -  Called internally by addLiquidity and addLiquidityETH
    ///@dev This function is used to add liquidity to a pair and will create the pair if it does not exist in the factory
    ///@param tokenA The first token in the pair
    ///@param tokenB The second token in the pair
    ///@param amountADesired The amount of tokenA to add as liquidity
    ///@param amountBDesired The amount of tokenB to add as liquidity
    ///@param amountAMin The minimum amount of tokenA to add as liquidity
    ///@param amountBMin The minimum amount of tokenB to add as liquidity

    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin
    ) internal virtual returns (uint256 amountA, uint256 amountB) {
        // create the pair if it doesn't exist yet
        if (
            IZeroXFactory(factory).getPair(tokenA, tokenB) == address(0)
        ) {
            IZeroXFactory(factory).createPair(tokenA, tokenB);
        }
        (uint256 reserveA, uint256 reserveB) = ZeroXLibrary.getReserves(
            factory,
            tokenA,
            tokenB
        );
        if (reserveA == 0 && reserveB == 0) {
            (amountA, amountB) = (amountADesired, amountBDesired);
        } else {
            uint256 amountBOptimal = ZeroXLibrary.quote(
                amountADesired,
                reserveA,
                reserveB
            );
            if (amountBOptimal <= amountBDesired) {
                require(
                    amountBOptimal >= amountBMin,
                    "ZeroXRouter: INSUFFICIENT_B_AMOUNT"
                );
                (amountA, amountB) = (amountADesired, amountBOptimal);
            } else {
                uint256 amountAOptimal = ZeroXLibrary.quote(
                    amountBDesired,
                    reserveB,
                    reserveA
                );
                assert(amountAOptimal <= amountADesired);
                require(
                    amountAOptimal >= amountAMin,
                    "ZeroXRouter: INSUFFICIENT_A_AMOUNT"
                );
                (amountA, amountB) = (amountAOptimal, amountBDesired);
            }
        }
    }

    ///@notice Adds liquidity to a pair
    ///@dev This function is used to add liquidity to a pair and will create the pair if it does not exist in the factory
    ///@param tokenA The first token in the pair
    ///@param tokenB The second token in the pair
    ///@param amountADesired The amount of tokenA to add as liquidity
    ///@param amountBDesired The amount of tokenB to add as liquidity
    ///@param amountAMin The minimum amount of tokenA to add as liquidity
    ///@param amountBMin The minimum amount of tokenB to add as liquidity
    ///@param to The address that will receive the LP tokens
    ///@param deadline The deadline for the transaction to be executed
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB, uint256 liquidity)
    {
        (amountA, amountB) = _addLiquidity(
            tokenA,
            tokenB,
            amountADesired,
            amountBDesired,
            amountAMin,
            amountBMin
        );
        address pair = ZeroXLibrary.pairFor(factory, tokenA, tokenB);
        TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
        TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);
        liquidity = IZeroXPair(pair).mint(to);
    }

    ///@notice Adds liquidity to a pair using ETH
    ///@dev This function is used to add liquidity to a pair and will create the pair if it does not exist in the factory
    ///@param token The token in the pair
    ///@param amountTokenDesired The amount of token to add as liquidity
    ///@param amountTokenMin The minimum amount of token to add as liquidity
    ///@param amountETHMin The minimum amount of ETH to add as liquidity
    ///@param to The address that will receive the LP tokens
    ///@param deadline The deadline for the transaction to be executed

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256 amountToken, uint256 amountETH, uint256 liquidity)
    {
        (amountToken, amountETH) = _addLiquidity(
            token,
            WETH,
            amountTokenDesired,
            msg.value,
            amountTokenMin,
            amountETHMin
        );
        address pair = ZeroXLibrary.pairFor(factory, token, WETH);
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);
        IWETH(WETH).deposit{value: amountETH}();
        assert(IWETH(WETH).transfer(pair, amountETH));
        liquidity = IZeroXPair(pair).mint(to);
        // refund dust eth, if any
        if (msg.value > amountETH)
            TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH);
    }

    // **** REMOVE LIQUIDITY ****
    ///@notice Removes liquidity from a pair
    ///@dev This function is used to remove liquidity from a pair
    ///@param tokenA The first token in the pair
    ///@param tokenB The second token in the pair
    ///@param liquidity The amount of LP tokens to remove
    ///@param amountAMin The minimum amount of tokenA to receive
    ///@param amountBMin The minimum amount of tokenB to receive
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        address pair = ZeroXLibrary.pairFor(factory, tokenA, tokenB);
        IZeroXPair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair
        (uint256 amount0, uint256 amount1) = IZeroXPair(pair).burn(to);
        (address token0, ) = ZeroXLibrary.sortTokens(tokenA, tokenB);
        (amountA, amountB) = tokenA == token0
            ? (amount0, amount1)
            : (amount1, amount0);
        require(
            amountA >= amountAMin,
            "ZeroXRouter: INSUFFICIENT_A_AMOUNT"
        );
        require(
            amountB >= amountBMin,
            "ZeroXRouter: INSUFFICIENT_B_AMOUNT"
        );
    }

    ///@notice Removes liquidity from a pair using ETH
    ///@dev This function is used to remove liquidity from a pair and will withdraw the ETH from the WETH contract
    ///@param token The token in the pair
    ///@param liquidity The amount of LP tokens to remove
    ///@param amountTokenMin The minimum amount of token to receive
    ///@param amountETHMin The minimum amount of ETH to receive
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        public
        virtual
        override
        ensure(deadline)
        returns (uint256 amountToken, uint256 amountETH)
    {
        (amountToken, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(token, to, amountToken);
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    ///@notice Removes liquidity from a pair using a permit
    ///@dev This function is used to remove liquidity from a pair using a permit and will withdraw the ETH from the WETH contract
    ///@param tokenA The first token in the pair
    ///@param tokenB The second token in the pair
    ///@param liquidity The amount of LP tokens to remove
    ///@param amountAMin The minimum amount of tokenA to receive
    ///@param amountBMin The minimum amount of tokenB to receive
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed
    ///@param approveMax Whether or not to approve the maximum amount of LP tokens
    ///@param v The recovery byte of the signature
    ///@param r The first 32 bytes of the signature
    ///@param s The second 32 bytes of the signature

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountA, uint256 amountB) {
        address pair = ZeroXLibrary.pairFor(factory, tokenA, tokenB);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IZeroXPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountA, amountB) = removeLiquidity(
            tokenA,
            tokenB,
            liquidity,
            amountAMin,
            amountBMin,
            to,
            deadline
        );
    }

    ///@notice Removes liquidity from a pair using ETH and a permit
    ///@dev This function is used to remove liquidity from a pair using a permit and will withdraw the ETH from the WETH contract
    ///@param token The token in the pair
    ///@param liquidity The amount of LP tokens to remove
    ///@param amountTokenMin The minimum amount of token to receive
    ///@param amountETHMin The minimum amount of ETH to receive
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed
    ///@param approveMax Whether or not to approve the maximum amount of LP tokens
    ///@param v The recovery byte of the signature
    ///@param r The first 32 bytes of the signature
    ///@param s The second 32 bytes of the signature
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        virtual
        override
        returns (uint256 amountToken, uint256 amountETH)
    {
        address pair = ZeroXLibrary.pairFor(factory, token, WETH);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IZeroXPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        (amountToken, amountETH) = removeLiquidityETH(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** REMOVE LIQUIDITY (supporting fee-on-transfer tokens) ****
    ///@notice Removes liquidity from a pair supporting fee-on-transfer tokens
    ///@dev This function is used to remove liquidity from a pair supporting fee-on-transfer tokens
    ///@param token The token in the pair
    ///@param liquidity The amount of LP tokens to remove
    ///@param amountTokenMin The minimum amount of token to receive
    ///@param amountETHMin The minimum amount of ETH to receive
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) public virtual override ensure(deadline) returns (uint256 amountETH) {
        (, amountETH) = removeLiquidity(
            token,
            WETH,
            liquidity,
            amountTokenMin,
            amountETHMin,
            address(this),
            deadline
        );
        TransferHelper.safeTransfer(
            token,
            to,
            IERC20(token).balanceOf(address(this))
        );
        IWETH(WETH).withdraw(amountETH);
        TransferHelper.safeTransferETH(to, amountETH);
    }

    ///@notice Removes liquidity from a pair supporting fee-on-transfer tokens using a permit
    ///@dev This function is used to remove liquidity from a pair supporting fee-on-transfer tokens using a permit
    ///@param token The token in the pair
    ///@param liquidity The amount of LP tokens to remove
    ///@param amountTokenMin The minimum amount of token to receive
    ///@param amountETHMin The minimum amount of ETH to receive
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed
    ///@param approveMax Whether or not to approve the maximum amount of LP tokens
    ///@param v The recovery byte of the signature
    ///@param r The first 32 bytes of the signature
    ///@param s The second 32 bytes of the signature
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual override returns (uint256 amountETH) {
        address pair = ZeroXLibrary.pairFor(factory, token, WETH);
        uint256 value = approveMax ? type(uint256).max : liquidity;
        IZeroXPair(pair).permit(
            msg.sender,
            address(this),
            value,
            deadline,
            v,
            r,
            s
        );
        amountETH = removeLiquidityETHSupportingFeeOnTransferTokens(
            token,
            liquidity,
            amountTokenMin,
            amountETHMin,
            to,
            deadline
        );
    }

    // **** SWAP ****
    // requires the initial amount to have already been sent to the first pair
    ///@notice Swaps an exact amount of tokens for another token
    ///@dev This function is used to swap an exact amount of tokens for another token
    ///@param amounts[] The amount of tokens to swap
    ///@param path[] The path of the swap
    ///@param _to The address that will receive the tokens

    function _swap(
        uint256[] memory amounts,
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint256 i; i < path.length - 1; ) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = ZeroXLibrary.sortTokens(input, output);
            uint256 amountOut = amounts[i + 1];
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOut)
                : (amountOut, uint256(0));
            address to = i < path.length - 2
                ? ZeroXLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            IZeroXPair(ZeroXLibrary.pairFor(factory, input, output))
                .swap(amount0Out, amount1Out, to, new bytes(0));

            unchecked {
                ++i;
            }
        }
    }

    ///@notice Swaps an exact amount of tokens for another token
    ///@dev This function is used to swap an exact amount of tokens for another token
    ///@param amountIn The amount of tokens to swap
    ///@param amountOutMin The minimum amount of tokens to receive
    ///@param path[] The path of the swap
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        amounts = ZeroXLibrary.getAmountsOut(factory, amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "ZeroXRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ZeroXLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    ///@notice Swaps tokens for an exact amount of tokens in return
    ///@dev It will revert if the amount of tokens received is less than the amount specified
    ///@param amountOut The amount of tokens to receive
    ///@param amountInMax The maximum amount of tokens to spend
    ///@param path[] The path of the swap
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        amounts = ZeroXLibrary.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= amountInMax,
            "ZeroXRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ZeroXLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, to);
    }

    ///@notice Swaps an exact amount of ETH for another token
    ///@dev This will revert if the amount of tokens received is less than the amount specified
    ///@param amountOutMin The minimum amount of tokens to receive
    ///@param path[] The path of the swap
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WETH, "ZeroXRouter: INVALID_PATH");
        amounts = ZeroXLibrary.getAmountsOut(factory, msg.value, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "ZeroXRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(
            IWETH(WETH).transfer(
                ZeroXLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
    }

    ///@notice Swaps tokens for an exact amount of ETH in return
    ///@dev It will revert if the amount of ETH received is less than the amount specified
    ///@param amountOut The amount of ETH to receive
    ///@param amountInMax The maximum amount of tokens to spend
    ///@param path[] The path of the swap
    ///@param to The address that will receive the ETH
    ///@param deadline The deadline for the transaction to be executed
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(
            path[path.length - 1] == WETH,
            "ZeroXRouter: INVALID_PATH"
        );
        amounts = ZeroXLibrary.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= amountInMax,
            "ZeroXRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ZeroXLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    ///@notice Swaps an exact amount of tokens for ETH
    ///@dev This will revert if the amount of ETH received is less than the amount specified
    ///@param amountIn The amount of tokens to swap
    ///@param amountOutMin The minimum amount of ETH to receive
    ///@param path[] The path of the swap
    ///@param to The address that will receive the ETH
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(
            path[path.length - 1] == WETH,
            "ZeroXRouter: INVALID_PATH"
        );
        amounts = ZeroXLibrary.getAmountsOut(factory, amountIn, path);
        require(
            amounts[amounts.length - 1] >= amountOutMin,
            "ZeroXRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ZeroXLibrary.pairFor(factory, path[0], path[1]),
            amounts[0]
        );
        _swap(amounts, path, address(this));
        IWETH(WETH).withdraw(amounts[amounts.length - 1]);
        TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
    }

    ///@notice Swaps ETH for an exact amount of tokens
    ///@dev It will revert if the amount of tokens received is less than the amount specified
    ///@param amountOut The amount of tokens to receive
    ///@param path[] The path of the swap
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    )
        external
        payable
        virtual
        override
        ensure(deadline)
        returns (uint256[] memory amounts)
    {
        require(path[0] == WETH, "ZeroXRouter: INVALID_PATH");
        amounts = ZeroXLibrary.getAmountsIn(factory, amountOut, path);
        require(
            amounts[0] <= msg.value,
            "ZeroXRouter: EXCESSIVE_INPUT_AMOUNT"
        );
        IWETH(WETH).deposit{value: amounts[0]}();
        assert(
            IWETH(WETH).transfer(
                ZeroXLibrary.pairFor(factory, path[0], path[1]),
                amounts[0]
            )
        );
        _swap(amounts, path, to);
        // refund dust eth, if any
        if (msg.value > amounts[0])
            TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]);
    }

    // **** SWAP (supporting fee-on-transfer tokens) ****
    // requires the initial amount to have already been sent to the first pair
    ///@notice Internal - Swaps an exact amount of tokens for another token supporting fee-on-transfer tokens
    ///@dev This function is used to swap an exact amount of tokens for another token supporting fee-on-transfer tokens
    ///@param path[] The path of the swap
    ///@param _to The address that will receive the tokens
    function _swapSupportingFeeOnTransferTokens(
        address[] memory path,
        address _to
    ) internal virtual {
        for (uint256 i; i < path.length - 1; ) {
            (address input, address output) = (path[i], path[i + 1]);
            (address token0, ) = ZeroXLibrary.sortTokens(input, output);
            IZeroXPair pair = IZeroXPair(
                ZeroXLibrary.pairFor(factory, input, output)
            );
            uint256 amountInput;
            uint256 amountOutput;
            {
                // scope to avoid stack too deep errors
                (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
                (uint256 reserveInput, uint256 reserveOutput) = input == token0
                    ? (reserve0, reserve1)
                    : (reserve1, reserve0);
                amountInput =
                    IERC20(input).balanceOf(address(pair)) -
                    reserveInput;
                amountOutput = ZeroXLibrary.getAmountOut(
                    amountInput,
                    reserveInput,
                    reserveOutput
                );
            }
            (uint256 amount0Out, uint256 amount1Out) = input == token0
                ? (uint256(0), amountOutput)
                : (amountOutput, uint256(0));
            address to = i < path.length - 2
                ? ZeroXLibrary.pairFor(factory, output, path[i + 2])
                : _to;
            pair.swap(amount0Out, amount1Out, to, new bytes(0));

            unchecked {
                ++i;
            }
        }
    }

    ///@notice Swaps an exact amount of tokens for another token supporting fee-on-transfer tokens
    ///@dev This will revert if the amount of tokens received is less than the amount specified
    ///@param amountIn The amount of tokens to swap
    ///@param amountOutMin The minimum amount of tokens to receive
    ///@param path[] The path of the swap
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executed
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ZeroXLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >=
                amountOutMin,
            "ZeroXRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    ///@notice Swaps an exact amount of ETH for another token supporting fee-on-transfer tokens
    ///@dev This will revert if the amount of tokens received is less than the amount specified
    ///@param amountOutMin The minimum amount of tokens to receive
    ///@param path[] The path of the swap
    ///@param to The address that will receive the tokens
    ///@param deadline The deadline for the transaction to be executeds
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable virtual override ensure(deadline) {
        require(path[0] == WETH, "ZeroXRouter: INVALID_PATH");
        uint256 amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(
            IWETH(WETH).transfer(
                ZeroXLibrary.pairFor(factory, path[0], path[1]),
                amountIn
            )
        );
        uint256 balanceBefore = IERC20(path[path.length - 1]).balanceOf(to);
        _swapSupportingFeeOnTransferTokens(path, to);
        require(
            IERC20(path[path.length - 1]).balanceOf(to) - balanceBefore >=
                amountOutMin,
            "ZeroXRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
    }

    ///@notice Swaps an exact amount of tokens for ETH supporting fee-on-transfer tokens
    ///@dev This will revert if the amount of ETH received is less than the amount specified
    ///@param amountIn The amount of tokens to swap
    ///@param amountOutMin The minimum amount of ETH to receive
    ///@param path[] The path of the swap
    ///@param to The address that will receive the ETH
    ///@param deadline The deadline for the transaction to be executed
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) {
        require(
            path[path.length - 1] == WETH,
            "ZeroXRouter: INVALID_PATH"
        );
        TransferHelper.safeTransferFrom(
            path[0],
            msg.sender,
            ZeroXLibrary.pairFor(factory, path[0], path[1]),
            amountIn
        );
        _swapSupportingFeeOnTransferTokens(path, address(this));
        uint256 amountOut = IERC20(WETH).balanceOf(address(this));
        require(
            amountOut >= amountOutMin,
            "ZeroXRouter: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(to, amountOut);
    }

    // **** LIBRARY FUNCTIONS ****
    ///@notice Returns the price of an asset against another
    ///@dev This function is used to get the price of an asset against another
    ///@return amountB The price of the asset against another
    ///@param amountA The amount of the first asset
    ///@param reserveA The reserve of the first asset
    ///@param reserveB The reserve of the second asset

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) public pure virtual override returns (uint256 amountB) {
        return ZeroXLibrary.quote(amountA, reserveA, reserveB);
    }

    ///@notice Returns the amount of tokens out for a given amount of tokens in accounting for fees and slippage
    ///@dev Uses the library to call getAmountOut and does calculations to account for fees and slippage
    ///@return amountOut The amount of tokens out for a given amount of tokens in accounting for fees and slippage
    ///@param amountIn The amount of tokens in
    ///@param reserveIn The reserve of the token in
    ///@param reserveOut The reserve of the token out

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountOut) {
        return ZeroXLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
    }

    ///@notice Returns the amount of tokens in for a given amount of tokens out accounting for fees and slippage
    ///@dev Uses the library to call getAmountIn and does calculations to account for fees and slippage
    ///@return amountIn The amount of tokens in for a given amount of tokens out accounting for fees and slippage
    ///@param amountOut The amount of tokens out
    ///@param reserveIn The reserve of the token in
    ///@param reserveOut The reserve of the token out
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure virtual override returns (uint256 amountIn) {
        return ZeroXLibrary.getAmountIn(amountOut, reserveIn, reserveOut);
    }

    ///@notice Returns the amount of tokens out for a given amount of tokens in accounting for fees and slippage
    ///@dev Uses the library to call getAmountsOut and does calculations to account for fees and slippage
    ///@return amounts The amount of tokens out for a given amount of tokens in accounting for fees and slippage
    ///@param amountIn The amount of tokens in
    ///@param path The path of the swap

    function getAmountsOut(
        uint256 amountIn,
        address[] memory path
    ) public view virtual override returns (uint256[] memory amounts) {
        return ZeroXLibrary.getAmountsOut(factory, amountIn, path);
    }

    ///@notice Returns the amount of tokens in for a given amount of tokens out accounting for fees and slippage
    ///@dev Uses the library to call getAmountsIn and does calculations to account for fees and slippage
    ///@return amounts The amount of tokens in for a given amount of tokens out accounting for fees and slippage
    ///@param amountOut The amount of tokens out
    ///@param path The path of the swap
    function getAmountsIn(
        uint256 amountOut,
        address[] memory path
    ) public view virtual override returns (uint256[] memory amounts) {
        return ZeroXLibrary.getAmountsIn(factory, amountOut, path);
    }
}
