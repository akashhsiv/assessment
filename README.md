# Crypto Research (Flutter)

A Flutter crypto-market research mini app implemented with feature-first MVVM, Riverpod, Dio, fl_chart and SharedPreferences. The app calls only the supplied FastAPI deployment (`https://crypto-be.vercel.app`) and does not modify or call CoinPaprika directly.

## Run locally

This workspace contains the complete `lib/` source, tests and package manifest. Platform runner folders are not included because Flutter/Dart are not installed in the build environment. From the project root on a machine with Flutter installed, scaffold them once, then run:

```bash
flutter create --platforms=android,ios,web .
flutter pub get
flutter analyze
flutter test
flutter run
```

## Structure

- `core/`: Dio setup, constants, theme, reusable notices/state panels and formatting.
- `features/market/`: ticker/global models, API service, pagination/filter/sort ViewModel, market and coin detail views.
- `features/watchlist/`: SharedPreferences persistence and watchlist ViewModel/view.
- `features/search/`: debounced search over the locally loaded market ticker list.
- `shared/`: reserved for cross-feature additions.

## API/data notes

- Tickers are requested with the backend's `/api/market/tickers?page=…&per_page=20` endpoint. Pages are appended, duplicate IDs are ignored, and failed next-page requests do not discard loaded rows.
- The Flutter client accepts both the currently deployed `/api/market/global` ticker-array response and a global-statistics object. If the latter includes `market_cap_change_24h`, the dashboard displays it; otherwise it labels the change unavailable.
- Optional backend replacements are in `backend_patch/`: they call CoinPaprika's dedicated `/global` endpoint and cache ticker snapshots for 60 seconds per warm serverless instance. See that folder's README before deploying.
- The backend has no historical-price endpoint. The details screen includes selectable periods and a fl_chart integration point, but intentionally shows an unavailable state rather than fabricating points.
- Any backend `source: mock` response is labeled as illustrative, not verified live data.
- Watchlist entries are stored locally as JSON snapshots, so the list remains available offline and across app restarts.
