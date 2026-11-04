import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/coin_model.dart';

enum ChartPeriod { day, week, month, quarter, year }

final coinDetailsViewModelProvider =
    NotifierProvider.family<CoinDetailsViewModel, ChartPeriod, CoinModel>(
        CoinDetailsViewModel.new);

class CoinDetailsViewModel extends FamilyNotifier<ChartPeriod, CoinModel> {
  @override
  ChartPeriod build(CoinModel coin) => ChartPeriod.day;
  void selectPeriod(ChartPeriod period) => state = period;
  // No historical-price endpoint exists yet; keep chart data empty rather than fabricate a series.
  List<(double, double)> get historicalPoints => const [];
}
