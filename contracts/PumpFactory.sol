// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IUniswapV2Router02 {
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    )
        external
        payable
        returns (uint amountToken, uint amountETH, uint liquidity);
    function WETH() external view returns (address);
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256) external;
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address owner) external view returns (uint256);
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract PumpToken {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public factory;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory");
        _;
    }

    constructor(string memory _name, string memory _symbol, address _creator) {
        name = _name;
        symbol = _symbol;
        factory = msg.sender;
        _mint(_creator, 1 ether);
    }

    function _mint(address to, uint256 amount) internal {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function mintFromFactory(address to, uint256 amount) external onlyFactory {
        _mint(to, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(
            allowance[from][msg.sender] >= amount,
            "Insufficient allowance"
        );
        balanceOf[from] -= amount;
        allowance[from][msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}

contract PumpCloneFactory is Ownable, ReentrancyGuard {
    struct TokenInfo {
        address creator;
        address tokenAddress;
        uint256 vReserveEth;
        uint256 vReserveToken;
        uint256 rReserveEth;
        int256 rReserveToken;
        bool liquidityMigrated;
    }

    mapping(address => TokenInfo) public tokens;

    address public uniswapRouter;
    address public WETH;

    uint256 public V_ETH_RESERVE;
    uint256 public V_TOKEN_RESERVE;
    uint256 public R_TOKEN_RESERVE;
    uint256 public TRADE_FEE_BPS;
    uint256 public BPS_DENOMINATOR;
    uint256 public LIQUIDITY_MIGRATION_FEE;
    uint256 public totalFee;

    event TokenLaunched(
        address indexed token,
        string name,
        string symbol,
        address indexed creator
    );
    event TokensPurchased(
        address indexed token,
        address indexed buyer,
        uint256 amount,
        uint256 cost
    );
    event TokensSold(
        address indexed token,
        address indexed seller,
        uint256 amount,
        uint256 refund
    );
    event LiquiditySwapped(
        address indexed token,
        uint256 tokenAmount,
        uint256 ethAmount
    );

    event ClaimedFee(uint256 amount);

    constructor(address _router) Ownable(msg.sender) {
        uniswapRouter = _router;
        WETH = IUniswapV2Router02(_router).WETH();

        V_ETH_RESERVE = 15 ether / 1000;
        V_TOKEN_RESERVE = 1073000000 ether;
        R_TOKEN_RESERVE = 793100000 ether;
        TRADE_FEE_BPS = 100; // 1% fee in basis points
        BPS_DENOMINATOR = 10000;
        LIQUIDITY_MIGRATION_FEE = 18 ether / 1000;
    }

    function launchToken(
        string memory _name,
        string memory _symbol
    ) external payable {
        PumpToken token = new PumpToken(_name, _symbol, msg.sender);
        TokenInfo storage info = tokens[address(token)];
        info.creator = msg.sender;
        info.tokenAddress = address(token);
        info.rReserveEth = 0;
        info.rReserveToken = int256(R_TOKEN_RESERVE);
        info.vReserveEth = V_ETH_RESERVE;
        info.vReserveToken = V_TOKEN_RESERVE;

        if (msg.value > 0) {
            uint256 fee = (msg.value * TRADE_FEE_BPS) / BPS_DENOMINATOR;
            uint256 netEthIn = msg.value - fee;
            (
                uint256 newReserveEth,
                uint256 newReserveToken
            ) = _calculateReserveAfterBuy(
                    V_ETH_RESERVE,
                    V_TOKEN_RESERVE,
                    netEthIn
                );
            uint256 tokensOut = info.vReserveToken - newReserveToken;
            info.vReserveEth = newReserveEth;
            info.vReserveToken = newReserveToken;
            info.rReserveEth = netEthIn;
            info.rReserveToken -= int256(tokensOut);

            token.mintFromFactory(msg.sender, tokensOut);
            emit TokensPurchased(
                address(token),
                msg.sender,
                tokensOut,
                msg.value
            );
            totalFee += fee;
        }
        info.liquidityMigrated = false;

        emit TokenLaunched(address(token), _name, _symbol, msg.sender);
    }

    function _calculateReserveAfterBuy(
        uint256 reserveEth,
        uint256 reserveToken,
        uint256 ethIn
    ) internal pure returns (uint256, uint256) {
        uint256 newReserveEth = ethIn + reserveEth;
        uint256 newReserveToken = (reserveEth * reserveToken) / newReserveEth;
        return (newReserveEth, newReserveToken);
    }

    function sellToken(
        address _token,
        uint256 tokenAmount
    ) external nonReentrant {
        TokenInfo storage info = tokens[_token];
        require(info.tokenAddress != address(0), "Invalid token");
        require(tokenAmount > 0, "Amount must be greater than 0");
        require(!info.liquidityMigrated, "Trading moved to Uniswap");

        uint256 newReserveToken = info.vReserveToken + tokenAmount;
        uint256 newReserveEth = (info.vReserveEth * info.vReserveToken) /
            newReserveToken;

        uint256 grossEthOut = info.vReserveEth - newReserveEth;
        uint256 fee = (grossEthOut * TRADE_FEE_BPS) / BPS_DENOMINATOR;
        uint256 netEthOut = grossEthOut - fee;

        require(
            grossEthOut > 0 && grossEthOut <= info.rReserveEth,
            "Insufficient ETH in contract"
        );

        bool success = IERC20(_token).transferFrom(
            msg.sender,
            address(this),
            tokenAmount
        );
        require(success, "Transfer failed");

        info.vReserveEth = newReserveEth;
        info.vReserveToken = newReserveToken;
        info.rReserveEth -= grossEthOut;
        info.rReserveToken += int256(tokenAmount);

        payable(msg.sender).transfer(netEthOut);
        totalFee += fee;

        emit TokensSold(_token, msg.sender, tokenAmount, netEthOut);
    }

    function updateReserves(
        uint256 _vEthReserve,
        uint256 _vTokenReserve,
        uint256 _rTokenReserve
    ) external onlyOwner {
        V_ETH_RESERVE = _vEthReserve;
        V_TOKEN_RESERVE = _vTokenReserve;
        R_TOKEN_RESERVE = _rTokenReserve;
    }

    function updateFeeRate(uint256 value) external onlyOwner {
        TRADE_FEE_BPS = value;
    }

    function updateLiquidityMigrationFee(uint256 value) external onlyOwner {
        LIQUIDITY_MIGRATION_FEE = value;
    }

    function claimFee(address to) external onlyOwner {
        uint256 feeAmount = totalFee;
        totalFee = 0;
        payable(to).transfer(feeAmount);
        emit ClaimedFee(feeAmount);
    }

    receive() external payable {}
}
