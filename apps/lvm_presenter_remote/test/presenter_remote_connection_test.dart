import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_presenter_remote/presenter_remote_connection.dart';

void main() {
  test('used pairing link asks for a new QR', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final connection = PresenterRemoteConnection(deviceName: 'QA phone');
    addTearDown(() async {
      connection.dispose();
      await server.close(force: true);
    });

    final serving = server.first.then((request) async {
      final peer = await WebSocketTransformer.upgrade(request);
      await for (final raw in peer) {
        final message = jsonDecode(raw as String) as Map<String, dynamic>;
        if (message['type'] != 'pair.request') continue;
        peer.add(
          jsonEncode({
            'schemaVersion': '0.1',
            'type': 'pair.rejected',
            'code': 'invalid_pairing',
          }),
        );
        break;
      }
    });

    await connection.connect(
      PresenterRemotePairingLink(
        host: InternetAddress.loopbackIPv4.address,
        port: server.port,
        pairingId: 'used-pairing',
        pairingSecret: 'used-secret',
      ),
    );
    await serving;
    await _waitFor(
      () => connection.status == PresenterRemoteConnectionStatus.error,
    );
    expect(connection.errorMessage, contains('Generá uno nuevo'));
    expect(connection.snapshot, isNull);
  });

  test(
    'server shutdown clears the live snapshot and disconnects controls',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final connection = PresenterRemoteConnection(deviceName: 'QA phone');
      WebSocket? peer;
      addTearDown(() async {
        connection.dispose();
        await peer?.close();
        await server.close(force: true);
      });

      final serving = server.first.then((request) async {
        peer = await WebSocketTransformer.upgrade(request);
        await for (final raw in peer!) {
          final message = jsonDecode(raw as String) as Map<String, dynamic>;
          if (message['type'] != 'pair.request') continue;
          peer!.add(
            jsonEncode({'schemaVersion': '0.1', 'type': 'pair.pending'}),
          );
          peer!.add(
            jsonEncode({
              'schemaVersion': '0.1',
              'type': 'pair.approved',
              'sessionToken': 'test-session',
            }),
          );
          peer!.add(
            jsonEncode({
              'schemaVersion': '0.1',
              'type': 'state.snapshot',
              'show': {'id': 'culto-qa', 'title': 'Culto QA'},
              'current': {'itemIndex': 0, 'slideIndex': 4, 'slideCount': 5},
              'output': {'isLive': true, 'isCleared': false},
            }),
          );
          break;
        }
      });

      await connection.connect(
        PresenterRemotePairingLink(
          host: InternetAddress.loopbackIPv4.address,
          port: server.port,
          pairingId: 'test-pairing',
          pairingSecret: 'test-secret',
        ),
      );
      await serving;
      await _waitFor(() => connection.snapshot?.slideIndex == 4);
      expect(connection.status, PresenterRemoteConnectionStatus.connected);

      await peer!.close();
      await _waitFor(
        () => connection.status == PresenterRemoteConnectionStatus.disconnected,
      );
      expect(connection.snapshot, isNull);
    },
  );
}

Future<void> _waitFor(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw StateError('Timed out waiting for remote state');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
