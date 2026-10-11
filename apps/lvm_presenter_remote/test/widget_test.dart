import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_presenter_remote/main.dart';

void main() {
  testWidgets('shows the presenter remote control workspace', (tester) async {
    await tester.pumpWidget(const LvmPresenterRemoteApp());
    expect(find.text('Sin conexión'), findsOneWidget);
    expect(lvmPresenterRemoteBoundariesReady(), isFalse);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Conexión'));
    await tester.pumpAndSettle();
    expect(find.text('Conectar a Presenter'), findsOneWidget);
    expect(find.byKey(const Key('scan-presenter-qr')), findsOneWidget);
    expect(find.byKey(const Key('connect-presenter')), findsOneWidget);
    expect(find.text('Blackout'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Biblia'));
    await tester.pumpAndSettle();
    expect(find.text('Salmo 23'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Canciones'));
    await tester.pumpAndSettle();
    expect(find.text('Cantamos con fe'), findsOneWidget);
  });
}
