// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "./Token.sol";
import "@uniswap-v2-core-1.0.1/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap-v2-core-1.0.1/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap-v2-periphery-1.1.0-beta.0/contracts/interfaces/IUniswapV2Router02.sol";

contract TokenFactory {
    error TokenFactory__InvalidToken();
    error TokenFactory__InvalidTokenSupply();
    error TokenFactory__InsufficientETH();

    uint public constant DECIMAL = 1e18; //10 ** 18;
    uint public constant MAX_SUPPLY = (1e9) * DECIMAL; //(10**9) * DECIMAL;
    uint public constant INITIAL_SUPPLY = (MAX_SUPPLY * 20) / 100;

    uint public constant K = 46875;
    uint public constant OFFSET_SUPPLY = 18750000000000000000000000000000;
    uint public constant SCALING_FACTOR = 1e39;
    uint public constant FUNDING_GOAL = 30 ether;
    address public constant UNISWAP_V2_FACTOR =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address public constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    mapping(address => bool) public tokens;
    mapping(address => uint) public collatral; // amount of eth received
    mapping(address => mapping(address => uint)) public balances;

    function createToken(
        string memory _name,
        string memory _symbol
    ) external returns (address) {
        Token _tokenaddress = new Token(_name, _symbol, INITIAL_SUPPLY);
        tokens[address(_tokenaddress)] = true;
        return address(_tokenaddress);
    }

    function buy(address _tokenAddress, uint _amount) external payable {
        require(tokens[_tokenAddress], TokenFactory__InvalidToken());
        Token token = Token(_tokenAddress);
        uint avaliableSupply = MAX_SUPPLY -
            INITIAL_SUPPLY -
            token.totalSupply();

        require(_amount <= avaliableSupply, TokenFactory__InvalidTokenSupply());
        // calculate amount eth to buy
        uint requiredEth = calRequiredEth(_tokenAddress, _amount);

        require(msg.value >= requiredEth, TokenFactory__InsufficientETH());
        collatral[_tokenAddress] += requiredEth;
        balances[_tokenAddress][msg.sender] += _amount;

        token.mint(address(this), _amount);
        if (collatral[_tokenAddress] >= FUNDING_GOAL) {
            // create LP pool
            address _pairAddress = _createLP(_tokenAddress);
            // provide liquidity
            uint _liquidity = _provideLiquidity(
                _tokenAddress,
                INITIAL_SUPPLY,
                collatral[_tokenAddress]
            );
            // burn lp tokens
            _burnLpTokens(_pairAddress, _liquidity);

        }

    }

    function calRequiredEth(
        address _tokenAddress,
        uint _amount
    ) public view returns (uint) {
        Token token = Token(_tokenAddress);
        uint b = token.totalSupply() - INITIAL_SUPPLY + _amount;
        uint a = token.totalSupply() - INITIAL_SUPPLY;
        uint f_a = K * a + OFFSET_SUPPLY;
        uint f_b = K * b + OFFSET_SUPPLY;
        return ((b - a) * (f_a + f_b)) / (2 * SCALING_FACTOR);
    }

    function _createLP(address _tokenAddress) public returns (address _pair) {
        // Token token = Token(_tokenAddress);
        IUniswapV2Factory factory = IUniswapV2Factory(UNISWAP_V2_FACTOR);
        IUniswapV2Router02 router = IUniswapV2Router02(UNISWAP_V2_ROUTER);

        _pair = factory.createPair(_tokenAddress, router.WETH());
    }

    function _provideLiquidity(
        address _tokenAddress,
        uint _tokenAmount,
        uint _ethAmount
    ) public returns (uint) {
        Token token = Token(_tokenAddress);
        IUniswapV2Router02 _router = IUniswapV2Router02(UNISWAP_V2_ROUTER);

        token.approve(UNISWAP_V2_ROUTER, _tokenAmount);
        (, , uint liquidity) = _router.addLiquidityETH{value: _ethAmount}(
            _tokenAddress,
            _tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(this),
            block.timestamp
        );

        collatral[_tokenAddress] = 0;

        return liquidity;
    }

    function _burnLpTokens(address _pairAddress, uint _amount) internal {
        IUniswapV2Pair pool = IUniswapV2Pair(_pairAddress);
        pool.transfer(address(0),_amount);
    }


    function withdraw(address _tokenAddress,address to) external {
        require(tokens[_tokenAddress], TokenFactory__InvalidToken());
        uint balance = balances[_tokenAddress][msg.sender];
        require(balance > 0,"balance must be greater than 0");
        balances[_tokenAddress][msg.sender] = 0;
        Token token = Token(_tokenAddress);
        token.transfer(to,balance);

    }
}
