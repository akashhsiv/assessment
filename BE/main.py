from fastapi import FastAPI, Query

from services.coin_service import get_global_market, get_ticker_page
from services.mock_data import get_mock_global_market, get_mock_tickers

app = FastAPI(title="Crypto Research API")


@app.get("/")
def home():
    return {"message": "Crypto API is running"}


@app.get("/api/market/global")
async def global_market():
    try:
        data = await get_global_market()
        return {"success": True, "source": "live", "data": data}
    except Exception as exc:
        # Keep the frontend's existing fallback contract; never label this as live.
        print(f"CoinPaprika global endpoint failed: {exc}")
        return {
            "success": False,
            "source": "mock",
            "data": get_mock_global_market(),
        }


@app.get("/api/market/tickers")
async def market_tickers(
    page: int = Query(default=1, ge=1),
    per_page: int = Query(default=20, ge=1, le=100),
):
    try:
        rows, pagination = await get_ticker_page(page=page, per_page=per_page)
        source = "live"
    except Exception as exc:
        print(f"CoinPaprika ticker endpoint failed: {exc}")
        all_rows = get_mock_tickers()
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
        source = "mock"

    return {
        "success": True,
        "source": source,
        "data": rows,
        "pagination": pagination,
    }
