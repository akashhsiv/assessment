"""CoinPaprika client with short process-local caching for warm Vercel instances.

The cache is best-effort: serverless cold starts/instances do not share memory.
"""
from __future__ import annotations

import asyncio
import time
from datetime import datetime, timedelta, timezone
from typing import Any

import httpx

BASE_URL = "https://api.coinpaprika.com/v1"
CACHE_TTL_SECONDS = 60
HISTORY_CACHE_TTL_SECONDS = 300
UPSTREAM_TIMEOUT_SECONDS = 12.0
TICKER_LIMIT = 2000

_global_cache: tuple[float, dict[str, Any]] | None = None
_ticker_cache: tuple[float, list[dict[str, Any]]] | None = None
_history_cache: dict[tuple[str, str], tuple[float, list[dict[str, Any]]]] = {}
_global_lock = asyncio.Lock()
_ticker_lock = asyncio.Lock()
_history_lock = asyncio.Lock()


async def _get_json(path: str, params: dict[str, Any] | None = None) -> Any:
    async with httpx.AsyncClient(timeout=UPSTREAM_TIMEOUT_SECONDS) as client:
        response = await client.get(f"{BASE_URL}{path}", params=params)
        response.raise_for_status()
        return response.json()


async def get_global_market() -> dict[str, Any]:
    """Return CoinPaprika's global-market object, not ticker rows."""
    global _global_cache
    now = time.monotonic()
    if _global_cache and now - _global_cache[0] < CACHE_TTL_SECONDS:
        return dict(_global_cache[1])

    async with _global_lock:
        now = time.monotonic()
        if _global_cache and now - _global_cache[0] < CACHE_TTL_SECONDS:
            return dict(_global_cache[1])
        data = await _get_json("/global")
        if not isinstance(data, dict):
            raise ValueError("CoinPaprika /global returned a non-object response")
        _global_cache = (time.monotonic(), data)
        return dict(data)


async def get_ticker_page(page: int, per_page: int) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    """Fetch/cache one upstream ticker snapshot, then return just the requested page."""
    global _ticker_cache
    now = time.monotonic()
    if not _ticker_cache or now - _ticker_cache[0] >= CACHE_TTL_SECONDS:
        async with _ticker_lock:
            now = time.monotonic()
            if not _ticker_cache or now - _ticker_cache[0] >= CACHE_TTL_SECONDS:
                data = await _get_json("/tickers", {"limit": TICKER_LIMIT})
                if not isinstance(data, list):
                    raise ValueError("CoinPaprika /tickers returned a non-list response")
                _ticker_cache = (time.monotonic(), [row for row in data if isinstance(row, dict)])

    assert _ticker_cache is not None
    all_rows = _ticker_cache[1]
    total = len(all_rows)
    total_pages = (total + per_page - 1) // per_page
    start = (page - 1) * per_page
    rows = all_rows[start : start + per_page]
    return rows, {
        "page": page,
        "per_page": per_page,
        "total": total,
        "total_pages": total_pages,
        "has_next": page < total_pages,
        "has_previous": page > 1,
    }


async def get_ticker_history(coin_id: str, period: str) -> list[dict[str, Any]]:
    """Fetch historical price points for the app's supported chart ranges.

    CoinPaprika's historical-ticks endpoint provides daily history and an hourly
    recent window on the public API. No chart points are fabricated on failure.
    """
    periods = {"24h": 1, "7d": 7, "30d": 30, "90d": 90, "1y": 365}
    if period not in periods:
        raise ValueError("Unsupported chart period")

    cache_key = (coin_id, period)
    cached = _history_cache.get(cache_key)
    now = time.monotonic()
    if cached and now - cached[0] < HISTORY_CACHE_TTL_SECONDS:
        return list(cached[1])

    async with _history_lock:
        cached = _history_cache.get(cache_key)
        now = time.monotonic()
        if cached and now - cached[0] < HISTORY_CACHE_TTL_SECONDS:
            return list(cached[1])

        end = datetime.now(timezone.utc)
        start = end - timedelta(days=periods[period])

        if period == "24h":
            start = end - timedelta(hours=23)
            interval = "1h"
        else:
            start = end - timedelta(days=periods[period])
            interval = "1d"
        params = {
            "start": start.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "end": end.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "interval": interval,
        }
        data = await _get_json(f"/tickers/{coin_id}/historical", params)
        if not isinstance(data, list):
            raise ValueError("CoinPaprika historical endpoint returned a non-list response")
        rows = [
            {"timestamp": row.get("timestamp"), "price": row.get("price")}
            for row in data
            if isinstance(row, dict) and row.get("timestamp") is not None and row.get("price") is not None
        ]
        rows.sort(key=lambda row: row["timestamp"])
        _history_cache[cache_key] = (time.monotonic(), rows)
        return list(rows)
