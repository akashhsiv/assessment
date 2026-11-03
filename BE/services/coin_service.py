from __future__ import annotations

import asyncio
import time
from typing import Any

import httpx

BASE_URL = "https://api.coinpaprika.com/v1"
CACHE_TTL_SECONDS = 60
UPSTREAM_TIMEOUT_SECONDS = 10.0
TICKER_LIMIT = 2000

_global_cache: tuple[float, dict[str, Any]] | None = None
_ticker_cache: tuple[float, list[dict[str, Any]]] | None = None
_global_lock = asyncio.Lock()
_ticker_lock = asyncio.Lock()


async def _get_json(path: str, params: dict[str, int] | None = None) -> Any:
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
    """Fetch/cache the upstream ticker snapshot, then return only one local page."""
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
    pagination = {
        "page": page,
        "per_page": per_page,
        "total": total,
        "total_pages": total_pages,
        "has_next": page < total_pages,
        "has_previous": page > 1,
    }
    return rows, pagination
