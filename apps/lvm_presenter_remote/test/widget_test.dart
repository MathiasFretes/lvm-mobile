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

    await tester.tap(find.widgetWithText(NavigationDestination, 'Más'));
    await tester.pumpAndSettle();
    expect(find.text('Apariencia'), findsOneWidget);
    await tester.tap(find.widgetWithText(ListTile, 'Conexión'));
    await tester.pumpAndSettle();
    expect(find.text('Conectar a Presenter'), findsOneWidget);
    expect(find.byKey(const Key('scan-presenter-qr')), findsOneWidget);
    expect(find.byKey(const Key('connect-presenter')), findsOneWidget);
    expect(find.text('Blackout'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

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

  testWidgets('culto lists real items and selects an item slide', (
    tester,
  ) async {
    final connection = _RecordingConnection();
    addTearDown(connection.dispose);
    connection.snapshot = PresenterRemoteSnapshot.fromMessage({
      'show': {'id': 'song', 'title': 'Cuán grande es Él'},
      'project': {'id': 'sunday', 'title': 'Culto Domingo'},
      'current': {'itemIndex': 1, 'slideIndex': 0, 'slideCount': 2},
      'output': {'isLive': true, 'isCleared': false},
      'items': [
        {
          'index': 0,
          'title': 'Bienvenida',
          'kind': 'show',
          'slides': [
            {'index': 0, 'label': 'Diapositiva 1'},
          ],
        },
        {
          'index': 1,
          'title': 'Cuán grande es Él',
          'kind': 'song',
          'slides': [
            {'index': 0, 'label': 'Verso'},
            {'index': 1, 'label': 'Coro'},
          ],
        },
      ],
    });
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ServiceOrderPage(connection: connection, onOpenTeam: () {}),
        ),
      ),
    );
    expect(find.text('Culto Domingo'), findsOneWidget);
    expect(find.text('Cuán grande es Él'), findsOneWidget);
    await tester.tap(find.text('Coro'));
    expect(connection.lastCommand, 'goToItem');
    expect(connection.itemIndex, 1);
    expect(connection.slideIndex, 1);
  });
}

class _RecordingConnection extends PresenterRemoteConnection {
  String? reference;
  String? lastCommand;
  int? itemIndex;
  int? slideIndex;

  _RecordingConnection() {
    status = PresenterRemoteConnectionStatus.connected;
  }

  @override
  void sendCommand(
    String command, {
    int? slideIndex,
    int? itemIndex,
    String? reference,
  }) {
    lastCommand = command;
    this.itemIndex = itemIndex;
    this.slideIndex = slideIndex;
    if (command == 'scripture') this.reference = reference;
  }
}
