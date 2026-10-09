import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_public/main.dart';

void main() {
  testWidgets('shows congregacion identity and its navigation', (tester) async {
    await tester.pumpWidget(const LvmPublicApp());
    expect(find.text('La Voz Misionera'), findsWidgets);
    expect(find.text('app.lavozmisionera.congregacion'), findsOneWidget);
    expect(find.byKey(const Key('lvm-emblem')), findsOneWidget);
    expect(lvmPublicBoundariesReady(), isFalse);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Visitas'));
    await tester.pumpAndSettle();
    expect(
      find.text('Esta sección todavía no consulta contenidos públicos.'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(NavigationDestination, 'Apariencia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}
