import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_mode_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return IconButton(
        tooltip: mode == ThemeMode.dark
            ? 'Switch to light theme'
            : 'Switch to dark theme',
        onPressed: () => ref.read(themeModeProvider.notifier).state =
            mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
        icon: Icon(mode == ThemeMode.dark
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined));
  }
}
