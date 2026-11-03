def get_mock_global_market():
    return {
        "market_cap_usd": 2500000000000,
        "volume_24h_usd": 85000000000,
        "bitcoin_dominance_percentage": 55.5,
        "cryptocurrencies_number": 10000,
        "markets_number": 50000
    }
def get_mock_tickers():
    return [
        {
            "id": "btc-bitcoin",
            "name": "Bitcoin",
            "symbol": "BTC",
            "rank": 1,
            "total_supply": 20106994,
            "max_supply": 21000000,
            "beta_value": 1.05,
            "first_data_at": "2010-07-17T00:00:00Z",
            "last_updated": "2026-11-02T09:59:15Z",
            "quotes": {
                "USD": {
                    "price": 78003.36,
                    "volume_24h": 13020089783.64,
                    "market_cap": 1568413138486,
                    "percent_change_24h": 0.09,
                    "percent_change_7d": -2.87,
                    "percent_change_30d": -8.19,
                    "percent_change_1y": -27.37,
                    "ath_price": 126173.17,
                    "ath_date": "2025-10-06T19:00:40Z",
                    "percent_from_price_ath": -38.15
                }
            }
        },
        {
            "id": "eth-ethereum",
            "name": "Ethereum",
            "symbol": "ETH",
            "rank": 2,
            "total_supply": 120000000,
            "max_supply": None,
            "beta_value": 1.12,
            "first_data_at": "2015-07-30T00:00:00Z",
            "last_updated": "2026-11-02T09:59:15Z",
            "quotes": {
                "USD": {
                    "price": 3200.50,
                    "volume_24h": 8500000000,
                    "market_cap": 384000000000,
                    "percent_change_24h": 1.25,
                    "percent_change_7d": 3.45,
                    "percent_change_30d": -4.20,
                    "percent_change_1y": 12.50,
                    "ath_price": 4878.26,
                    "ath_date": "2021-11-10T00:00:00Z",
                    "percent_from_price_ath": -34.39
                }
            }
        },
        {
            "id": "usdt-tether",
            "name": "Tether",
            "symbol": "USDT",
            "rank": 3,
            "total_supply": 180000000000,
            "max_supply": None,
            "beta_value": 0.01,
            "first_data_at": "2015-02-25T00:00:00Z",
            "last_updated": "2026-11-02T09:59:15Z",
            "quotes": {
                "USD": {
                    "price": 1.0,
                    "volume_24h": 45000000000,
                    "market_cap": 180000000000,
                    "percent_change_24h": 0.01,
                    "percent_change_7d": -0.02,
                    "percent_change_30d": 0.03,
                    "percent_change_1y": 0.10,
                    "ath_price": 1.32,
                    "ath_date": "2018-07-24T00:00:00Z",
                    "percent_from_price_ath": -24.24
                }
            }
        }
    ]