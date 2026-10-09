import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_design/lvm_design.dart';

void main() {
  test('light theme uses navy and gold', () {
    final scheme = LvmTheme.light().colorScheme;
    expect(scheme.primary, LvmColors.navy);
    expect(scheme.secondary, LvmColors.gold);
    expect(scheme.surface, LvmColors.neutral);
  });

  test('dark theme keeps navy surfaces and gold accent', () {
    final theme = LvmTheme.dark();
    expect(theme.colorScheme.primary, LvmColors.gold);
    expect(theme.colorScheme.surface, LvmColors.navy);
    expect(theme.scaffoldBackgroundColor, LvmColors.navyDeep);
  });

  testWidgets('emblem exposes the institutional symbols', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LvmEmblem()));
    expect(
      find.bySemanticsLabel(
        'Emblema de La Voz Misionera: libro abierto, paloma y llama',
      ),
      findsOneWidget,
    );
  });

  testWidgets('appearance switches theme preference', (tester) async {
    final controller = LvmThemeController();
    await tester.pumpWidget(
      MaterialApp(
        home: LvmAppearancePage(controller: controller),
      ),
    );
    await tester.tap(find.text('Oscuro'));
    await tester.pump();
    expect(controller.themeMode, ThemeMode.dark);
    await tester.tap(find.text('Claro'));
    await tester.pump();
    expect(controller.themeMode, ThemeMode.light);
    await tester.tap(find.text('Automático'));
    await tester.pump();
    expect(controller.themeMode, ThemeMode.system);
  });
}
