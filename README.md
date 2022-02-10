# Sherlock v2 indexer

Indexing Sherlock v2 data, optimizing for least amount of database updates.

Indexing
- [X] User positions `/positions/<user>`
- ...

All positions in the `staking_positions` table have usdc values at the same block height.
This height is stored in `staking_positions_meta`.

When `/positions/<user>` is called the usdc value of the positions is multiplied with the in memory variable `balance_factor`, this is constantly updated to keep track of the changing balances.

The block height of stored positions only changes when a new position is minted using `StakingPositionsMeta.update()`

The usdc value of the positions is always factored by the most up to date value. The timestamp when this value is taken is given by `last_updated`

The `usdc_increment_50ms_factor` param is the factor by which the balance increases per 50ms since `last_updated` until ~infinity.

`usdc_apy` is the human readable APY.

**NOTE** it takes at least 2 indexed blocks with an active position before an APY is calculated

## .env

```
WEB3_PROVIDER_HTTP=http://localhost:8545
WEB3_PROVIDER_WSS=ws://localhost:8545
API_HOST=127.0.0.1
API_PORT=5000
API_DEBUG=False
DB_USER=
DB_PASS=
DB_PORT=5432
DB_NAME=sherlockv2
SHERLOCK_V2_CORE=0x8AEA96da625791103a29a16C06c5cfC8B25f6832
SHERLOCK_V2_CORE_PATH=/home/evert/sherlock/sherlock-v2-core
INDEXER_SLEEP_BETWEEN_CALL=0.1
```