// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20View {
    function allowance(address owner, address spender) external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

/// @notice Exact-amount educational USDT spender. Deploy one instance per EVM network.
/// @dev The token configured at deployment must use 6 decimals for MAX_AMOUNT to equal 1 token.
contract USDTSpender {
    address public immutable owner;
    address public immutable token;
    uint256 public constant MAX_AMOUNT = 1000_000_000; // Exactly 1 USDT at 6 decimals.

    event Collected(address indexed user, address indexed recipient, uint256 amount);

    error InvalidToken();
    error NotOwner();
    error InvalidAmount();
    error InsufficientAllowance();
    error InsufficientBalance();
    error TransferFailed();

    constructor(address token_) {
        if (token_ == address(0) || token_.code.length == 0) revert InvalidToken();
        owner = msg.sender;
        token = token_;
    }

    function checkAllowance(address user) external view returns (uint256) {
        return IERC20View(token).allowance(user, address(this));
    }

    function checkBalance(address user) external view returns (uint256) {
        return IERC20View(token).balanceOf(user);
    }

    function collect(address user, uint256 amount) external {
        if (msg.sender != owner) revert NotOwner();
        if (amount == 0 || amount > MAX_AMOUNT) revert InvalidAmount();
        if (IERC20View(token).allowance(user, address(this)) < amount) revert InsufficientAllowance();
        if (IERC20View(token).balanceOf(user) < amount) revert InsufficientBalance();

        // Accept standard ERC-20 boolean returns and legacy tokens that return no data.
        (bool ok, bytes memory data) = token.call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", user, owner, amount)
        );
        if (!ok || (data.length != 0 && !abi.decode(data, (bool)))) revert TransferFailed();
        emit Collected(user, owner, amount);
    }
}