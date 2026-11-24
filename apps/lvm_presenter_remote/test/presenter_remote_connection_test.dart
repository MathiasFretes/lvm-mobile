import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_presenter_remote/presenter_remote_connection.dart';

void main() {
  for (final disposeWhileConnecting in [false, true]) {
    test('late handshake cannot restore connection after ${disposeWhileConnecting ? "dispose" : "disconnect"}', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final requested = Completer<HttpRequest>();
      final subscription = server.listen((request) => requested.complete(request));
      final connection = PresenterRemoteConnection(deviceName: 'Delayed QA');
      WebSocket? peer;
      var disposed = false;
      addTearDown(() async {
        if (!disposed) connection.dispose();
        await peer?.close();
        await subscription.cancel();
        await server.close(force: true);
      });
      var notifications = 0;
      connection.addListener(() => notifications++);
      final connecting = connection.connect(PresenterRemotePairingLink(
        host: InternetAddress.loopbackIPv4.address, port: server.port,
        pairingId: 'delayed-pairing', pairingSecret: 'delayed-secret',
      ));
      final request = await requested.future.timeout(const Duration(seconds: 3));
      if (disposeWhileConnecting) {
        connection.dispose();
        disposed = true;
      } else {
        await connection.disconnect();
      }
      final afterCancel = notifications;
      peer = await WebSocketTransformer.upgrade(request);
      final messages = <String>[];
      final completed = Completer<void>();
      peer!.listen((raw) {
        messages.add(raw as String);
        peer!.add(jsonEncode({'schemaVersion':'0.1', 'type':'pair.approved', 'sessionToken':'stale-session'}));
      }, onDone: () => completed.complete());
      await connecting;
      // A stale handshake must be closed, with no pairing or auth notification.
      await completed.future.timeout(const Duration(seconds: 3));
      expect(messages, isEmpty);
      expect(notifications, afterCancel);
      expect(connection.snapshot, isNull);
      if (!disposed) expect(connection.status, PresenterRemoteConnectionStatus.disconnected);
    });
  }

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
