# Future
Portfolio
    - JSON local storage
        - path pub
    - Upload to firebase

Searching
Animate everything

# Do Soon
Try home top appbar tabs

Icon
- Vector drawable
Splash screen

# Ideas
Exchange list for a coin
    - Instead of bringing up new page, show graph and options right under, expand and contract when tapped

# UI
Specific currency
- Aggregate Market Stats
    - Scrollable Column View
        - Details on coin
            - Amt in circulation
            - Market Cap
            - Price
            - Time period setting
                - High
                - Low
                - Volume
        - Sparkline
            - History length setting for each graph
                - 1h = 60 minute
                - 6h = 360 minute
                - 12h = 720 minute
                - 24h = 720 2 minute (&aggregate=2)
                - 3d = 72 hour
                - 7d = 168 hour
                - 1m = 720 hour
                - 3m = 720 3 hour (&aggregate=3)
                - 6m = 180 day
                - 1y = 365 day
        - OHLC
            - Candlestick width options by total history length 
                - Info
                    - Total Periods: 1hr, 6hr, 12hr, 24hr, 3d, 7d, 1m, 3m, 6m, 1y
                    - Width options: 1m, 2m, 3m, 5m, 10m, 15m, 30m, 1hr, 2hr, 4hr, 6hr, 12hr, 1d, 2d, 3d, 7d

                - 1h
                    - 1m (60), 2m (30), 3m (20)
                - 6h
                    - 5m (72), 10m (36), 15m (24)
                - 12h
                    - 10m (72), 15m (48), 30m (24)
                - 24h
                    - 15m (96), 30m (48), 1h (24)
                - 3D
                    - 1h (72), 2h (36), 4hr (18)
                - 7D
                    - 2h (84), 4h (42), 6h (28)
                - 1M
                    - 12h (60), 1d (30)
                - 3M
                    - 1d (90), 2d (45), 3d (30)
                - 6M
                    - 2d (90), 3d (60), 7d (26)
                - 1Y
                    - 7d (52), 14d (26)

        - Volume (base same width of OHLC)
        - Depth
- Markets
    - Listview of all markets
        - Each item: Market name - Price/24h


# Sources
- Data (Cryptowat.ch)
    - Orderbook (by exchange and trading pair): https://api.cryptowat.ch/markets/[exchange]/[pair]/orderbook

- Get OHLCV data from CryptoCompare but Orderbook for Depth graph will have to come from Cryptowatch
- Data (CryptoCompare)
    - OHLCV: https://min-api.cryptocompare.com/data/histo[minute/hour/day]?fsym=[from_symbol]&tsym=USD&limit=30&e=[exchange]&aggregate=[period_to_combine_oer]
    - ["Data"] -> first item is oldest