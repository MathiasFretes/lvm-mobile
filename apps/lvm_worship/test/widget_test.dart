import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_worship/main.dart';

void main() {
  testWidgets('shows worship identity and its navigation', (tester) async {
    await tester.pumpWidget(const LvmWorshipApp());
    expect(find.text('LVM Worship'), findsWidgets);
    expect(find.text('app.lavozmisionera.worship'), findsOneWidget);
    expect(find.byKey(const Key('lvm-emblem')), findsOneWidget);
    expect(lvmWorshipBoundariesReady(), isFalse);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Canciones'));
    await tester.pumpAndSettle();
    expect(
      find.text('Esta sección todavía no abre canciones ni repertorios.'),
      findsOneWidget,
    );
  });
}
