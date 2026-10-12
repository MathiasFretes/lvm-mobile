import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_presenter_remote/main.dart';
import 'package:lvm_presenter_remote/presenter_remote_connection.dart';
import 'package:lvm_presenter_remote/remote_dashboard.dart';

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

  testWidgets('tapping a Bible reference sends it to Presenter', (
    tester,
  ) async {
    final connection = _RecordingConnection();
    addTearDown(connection.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BiblePage(connection: connection)),
      ),
    );
    await tester.tap(find.text('Salmo 23:2'));
    await tester.pump();

    expect(connection.reference, '19.23.2');
  });
}

class _RecordingConnection extends PresenterRemoteConnection {
  String? reference;

  _RecordingConnection() {
    status = PresenterRemoteConnectionStatus.connected;
  }

  @override
  void sendCommand(String command, {int? slideIndex, String? reference}) {
    if (command == 'scripture') this.reference = reference;
  }
}
