import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_presenter_remote/main.dart';

void main() {
  testWidgets('shows presenter remote connection controls', (tester) async {
    await tester.pumpWidget(const LvmPresenterRemoteApp());
    expect(find.text('LVM Presenter Remote'), findsWidgets);
    expect(find.text('app.lavozmisionera.presenterremote'), findsOneWidget);
    expect(find.byKey(const Key('lvm-emblem')), findsOneWidget);
    expect(lvmPresenterRemoteBoundariesReady(), isFalse);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Conexión'));
    await tester.pumpAndSettle();
    expect(find.text('Conectar a Presenter'), findsOneWidget);
    expect(find.byKey(const Key('scan-presenter-qr')), findsOneWidget);
    expect(find.byKey(const Key('connect-presenter')), findsOneWidget);
    expect(find.text('Blackout'), findsOneWidget);
  });
}
