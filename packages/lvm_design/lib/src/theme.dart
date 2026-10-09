import 'package:flutter/material.dart';

import 'colors.dart';

enum LvmThemePreference { system, light, dark }

class LvmThemeController extends ChangeNotifier {
  LvmThemePreference _preference = LvmThemePreference.system;

  LvmThemePreference get preference => _preference;

  ThemeMode get themeMode => switch (_preference) {
    LvmThemePreference.system => ThemeMode.system,
    LvmThemePreference.light => ThemeMode.light,
    LvmThemePreference.dark => ThemeMode.dark,
  };

  set preference(LvmThemePreference value) {
    if (_preference == value) return;
    _preference = value;
    notifyListeners();
  }
}

abstract final class LvmTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: LvmColors.navy,
      brightness: Brightness.light,
    ).copyWith(
      primary: LvmColors.navy,
      onPrimary: Colors.white,
      secondary: LvmColors.gold,
      onSecondary: LvmColors.navy,
      surface: LvmColors.neutral,
      onSurface: LvmColors.navy,
    );
    return _theme(scheme, LvmColors.neutral, Colors.white);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: LvmColors.navy,
      brightness: Brightness.dark,
    ).copyWith(
      primary: LvmColors.gold,
      onPrimary: LvmColors.navy,
      secondary: LvmColors.gold,
      onSecondary: LvmColors.navy,
      surface: LvmColors.navy,
      onSurface: LvmColors.neutral,
    );
    return _theme(scheme, LvmColors.navyDeep, LvmColors.navy);
  }

  static ThemeData _theme(
    ColorScheme scheme,
    Color scaffold,
    Color navigation,
  ) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffold,
      appBarTheme: const AppBarTheme(
        backgroundColor: LvmColors.navy,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navigation,
        indicatorColor: LvmColors.gold.withValues(alpha: 0.45),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: scheme.brightness == Brightness.dark
                ? LvmColors.neutral
                : LvmColors.navy,
          );
        }),
      ),
    );
  }
}
