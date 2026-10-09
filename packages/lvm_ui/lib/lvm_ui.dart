library;

import 'package:flutter/material.dart';

/// Shared visual contract for the four LVM Android applications.
abstract final class LvmColors {
  static const navy = Color(0xFF1C2A39);
  static const navyRaised = Color(0xFF172033);
  static const gold = Color(0xFFC6A15B);
  static const background = Color(0xFFF6F7F9);
  static const surface = Colors.white;
  static const text = Color(0xFF2D3748);
  static const muted = Color(0xFF596474);
}

ThemeData lvmLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: LvmColors.navy,
    primary: LvmColors.navy,
    secondary: LvmColors.gold,
    surface: LvmColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: LvmColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: LvmColors.navy,
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: LvmColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class LvmBrandMark extends StatelessWidget {
  const LvmBrandMark({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'La Voz Misionera',
      image: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: LvmColors.gold,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, size: size * 0.58, color: LvmColors.navy),
      ),
    );
  }
}

class LvmFoundationApp extends StatelessWidget {
  const LvmFoundationApp({
    super.key,
    required this.product,
    required this.audience,
    required this.plannedFeatures,
  });

  final String product;
  final String audience;
  final List<String> plannedFeatures;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: product,
      theme: lvmLightTheme(),
      home: Scaffold(
        appBar: AppBar(title: Text(product)),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const LvmBrandMark(),
                  const SizedBox(height: 24),
                  Text(
                    product,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: LvmColors.navy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(audience),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Base Android en desarrollo',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Esta aplicación aún no está conectada a datos ni disponible para distribución.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Próximas funciones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  ...plannedFeatures.map(
                    (feature) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: LvmColors.navy,
                      ),
                      title: Text(feature),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
