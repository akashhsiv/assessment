import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'features/market/views/market_screen.dart';
import 'features/search/views/search_screen.dart';
import 'features/watchlist/views/watchlist_screen.dart';

void main() => runApp(const ProviderScope(child: CryptoResearchApp()));

class CryptoResearchApp extends ConsumerWidget {
  const CryptoResearchApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
        title: 'Crypto Research',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ref.watch(themeModeProvider),
        home: const AppShell(),
      );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  static const _screens = [MarketScreen(), WatchlistScreen(), SearchScreen()];
  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(index: _index, children: _screens),
        bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.insights_outlined),
                  selectedIcon: Icon(Icons.insights),
                  label: 'Market'),
              NavigationDestination(
                  icon: Icon(Icons.star_border_rounded),
                  selectedIcon: Icon(Icons.star_rounded),
                  label: 'Watchlist'),
              NavigationDestination(
                  icon: Icon(Icons.search_rounded), label: 'Search'),
            ]),
      );
}
