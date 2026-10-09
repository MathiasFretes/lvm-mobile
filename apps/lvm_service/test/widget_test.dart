import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_service/main.dart';

void main() {
  testWidgets('shows service identity and its navigation', (tester) async {
    await tester.pumpWidget(const LvmServiceApp());
    expect(find.text('LVM Service'), findsWidgets);
    expect(find.text('app.lavozmisionera.service'), findsOneWidget);
    expect(find.byKey(const Key('lvm-emblem')), findsOneWidget);
    expect(lvmServiceBoundariesReady(), isFalse);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Cultos'));
    await tester.pumpAndSettle();
    expect(
      find.text('Esta sección todavía no abre ni guarda cultos.'),
      findsOneWidget,
    );
  });
}
