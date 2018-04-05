# Future
Learn drawing for OHLC and Volume
    - Control total time period (assigned by sparkline time setting)
    - Divided into width options specific to total time

Portfolio
    - JSON local storage
        - path pub
    - Upload to firebase

Python backend for aggregate market depth stats
Searching coins

# Do Soon
- Data (Cryptowat.ch)
    - OHLCV: https://api.cryptowat.ch/markets/[exchange]/[pair]/ohlc?period=[periodseconds]
        - [ CloseTime, OpenPrice, HighPrice, LowPrice, ClosePrice, Volume ]
        - ?period=
            - 1m, 3m, 5m, 15m, 30m, 1hr, 2hr, 4hr, 6hr, 12hr, 1d, 3d, 1w (in seconds)
        - Returns 500 results
            - Last item in list is most recent
    - Orderbook (by exchange and trading pair): https://api.cryptowat.ch/markets/[exchange]/[pair]/orderbook

- Get OHLCV data from CryptoCompare but Orderbook for Depth graph will have to come from Cryptowatch
- Data (CryptoCompare)
    - OHLCV: https://min-api.cryptocompare.com/data/histo[minute/hour/day]?fsym=[from_symbol]&tsym=USD&limit=30&e=[exchange]

Download Coin Icon assets and display only if in list

Good looking market UI
- Specific market Page on click
Abbreviation options (5,000,000 -> 5M)


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
                - 24h = 1420 minute
                - 3d = 72 hour
                - 7d = 168 hour
                - 1m = 720 hour
                - 3m = 1420 hour
                - 6m = 180 day
                - 1y = 365 day
        - OHLC
            - Candlestick width options by total history length 
                - Info
                    - Total Periods: 1hr, 6hr, 12hr, 24hr, 3d, 7d, 1m, 3m, 6m, 1y
                    - Width options: 1m, 3m, 5m, 10m, 15m, 30m, 1hr, 2hr, 4hr, 6hr, 12hr, 1d, 3d, 7d

                - 1h
                    - 1m (60), 3m (20), 5m (12)
                - 6h
                    - 5m (72), 10m (36), 15m (24), 30m (12)
                - 12h
                    - 10m (72), 15m (48), 30m (24), 1h (12)
                - 24h
                    - 30m (48), 1h (24), 2hr (12)
                - 3d
                - 7d
                - 1m
                - 3m
                - 6m
                - 1y

        - Volume (base on same width of OHLC)
        - Depth
- Markets
    - Listview of all markets
        - Each item: Market name - Price/24h
