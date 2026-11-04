import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../market/models/coin_model.dart';

final watchlistServiceProvider =
    Provider<WatchlistService>((ref) => WatchlistService());

class WatchlistService {
  Future<List<CoinModel>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.watchlistStorageKey) ??
        const <String>[];
    return raw
        .map((s) {
          try {
            return CoinModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<CoinModel>()
        .toList();
  }

  Future<void> save(List<CoinModel> coins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(AppConstants.watchlistStorageKey,
        coins.map((c) => jsonEncode(c.toJson())).toList());
  }
}
