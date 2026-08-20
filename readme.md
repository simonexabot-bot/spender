# USDT exact-amount approval test

This project contains a single-button browser interface and an EVM Solidity spender contract capped at exactly 1 USDT (1,000,000 base units for a 6-decimal token).

## Polygon deployment

1. In Remix, compile `USDTSpender.sol` with Solidity 0.8.24.
2. Select **Injected Provider - MetaMask** and confirm Remix reports chain ID 137.
3. Deploy with Polygon USDT as the constructor argument: `0xc2132D05D31c914a87C6611C10748AEb04B58e8F`.
4. Copy the deployed contract address into the Polygon `spender` field in `index.html`.
5. Serve `index.html` through HTTPS. Do not open it as a `file://` page.

The existing Polygon spender address is retained in the configuration, but the interface verifies its bytecode, configured token, and 1-USDT cap before requesting approval. If that older deployment still has the incorrect 100-USDT cap, the interface will refuse to use it; deploy the corrected contract and replace the address.

## Other networks

Deploy a separate contract on each EVM chain, then fill that chain's `token` and `spender` values in `CHAINS`. Verify the official token address and its decimals before deployment. Solana and Bitcoin are not EVM chains and cannot use this Solidity contract or the injected EVM-wallet flow.

Automatic connection is intentionally silent: on load the page calls `eth_accounts`, which restores an already-authorized session without displaying a popup. A website cannot—and should not—force a new wallet connection without a user gesture. The single button requests a connection when needed, switches to Polygon when the current network lacks configured deployments, validates the spender, and requests exactly 1 USDT approval.