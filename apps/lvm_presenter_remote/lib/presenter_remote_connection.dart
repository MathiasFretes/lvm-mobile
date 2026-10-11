import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lvm_models/lvm_models.dart';

enum PresenterRemoteConnectionStatus {
  disconnected,
  connecting,
  waitingForApproval,
  connected,
  error,
}

class PresenterRemoteSnapshot {
  const PresenterRemoteSnapshot({
    required this.showTitle,
    required this.itemIndex,
    required this.slideIndex,
    required this.slideCount,
    required this.isLive,
    required this.isCleared,
  });

  final String? showTitle;
  final int? itemIndex;
  final int? slideIndex;
  final int? slideCount;
  final bool isLive;
  final bool isCleared;

  factory PresenterRemoteSnapshot.fromMessage(Map<String, Object?> value) {
    final show = value['show'] as Map<String, Object?>?;
    final current = value['current'] as Map<String, Object?>?;
    final output = value['output'] as Map<String, Object?>? ?? const {};
    return PresenterRemoteSnapshot(
      showTitle: show?['title'] as String?,
      itemIndex: current?['itemIndex'] as int?,
      slideIndex: current?['slideIndex'] as int?,
      slideCount: current?['slideCount'] as int?,
      isLive: output['isLive'] as bool? ?? false,
      isCleared: output['isCleared'] as bool? ?? false,
    );
  }
}

/// Android-only client for the versioned, local Presenter Remote protocol.
///
/// Pairing links and session tokens live only in memory. This client never
/// receives Service credentials or makes Internet connections.
class PresenterRemoteConnection extends ChangeNotifier {
  PresenterRemoteConnection({String? deviceName})
    : _deviceName = deviceName ?? Platform.localHostname,
      _deviceId = 'android-${DateTime.now().microsecondsSinceEpoch}';

  final String _deviceName;
  final String _deviceId;
  WebSocket? _socket;
  StreamSubscription<dynamic>? _messages;
  String? _sessionToken;

  PresenterRemoteConnectionStatus status =
      PresenterRemoteConnectionStatus.disconnected;
  PresenterRemoteSnapshot? snapshot;
  String? errorMessage;

  Future<void> connect(PresenterRemotePairingLink link) async {
    await disconnect(notify: false);
    status = PresenterRemoteConnectionStatus.connecting;
    errorMessage = null;
    notifyListeners();
    try {
      final socket = await WebSocket.connect(link.socketUri.toString())
          .timeout(const Duration(seconds: 8));
      _socket = socket;
      _messages = socket.listen(
        _receive,
        onDone: () {
          if (status != PresenterRemoteConnectionStatus.disconnected) {
            status = PresenterRemoteConnectionStatus.disconnected;
            notifyListeners();
          }
        },
        onError: (Object error) => _fail('La conexión se interrumpió.'),
      );
      _send({
        'type': 'pair.request',
        'pairingId': link.pairingId,
        'pairingSecret': link.pairingSecret,
        'device': {'id': _deviceId, 'name': _deviceName},
      });
    } on Object {
      _fail('No se pudo conectar con LVM Presenter en esta red.');
    }
  }

  void sendCommand(String command, {int? slideIndex}) {
    if (status != PresenterRemoteConnectionStatus.connected ||
        _sessionToken == null) {
      return;
    }
    _send({
      'type': 'command.$command',
      'sessionToken': _sessionToken,
      'slideIndex': ?slideIndex,
    });
  }

  Future<void> disconnect({bool notify = true}) async {
    await _messages?.cancel();
    _messages = null;
    await _socket?.close();
    _socket = null;
    _sessionToken = null;
    snapshot = null;
    status = PresenterRemoteConnectionStatus.disconnected;
    errorMessage = null;
    if (notify) notifyListeners();
  }

  void _receive(dynamic raw) {
    try {
      final decoded = jsonDecode(raw as String) as Map<String, dynamic>;
      if (decoded['schemaVersion'] != '0.1') return;
      final message = decoded.cast<String, Object?>();
      switch (message['type']) {
        case 'pair.pending':
          status = PresenterRemoteConnectionStatus.waitingForApproval;
          notifyListeners();
        case 'pair.approved':
          _sessionToken = message['sessionToken'] as String?;
          if (_sessionToken == null || _sessionToken!.isEmpty) {
            _fail('Presenter no confirmó la sesión.');
            return;
          }
          status = PresenterRemoteConnectionStatus.connected;
          notifyListeners();
        case 'state.snapshot':
        case 'state.changed':
          snapshot = PresenterRemoteSnapshot.fromMessage(message);
          notifyListeners();
        case 'pair.rejected':
          _fail('Presenter rechazó la solicitud de conexión.');
        case 'command.rejected':
          _fail('Presenter no pudo aplicar ese control.');
        case 'error':
          _fail('Presenter recibió un mensaje no válido.');
      }
    } on Object {
      _fail('Presenter envió una respuesta no válida.');
    }
  }

  void _send(Map<String, Object?> message) {
    _socket?.add(jsonEncode({'schemaVersion': '0.1', ...message}));
  }

  void _fail(String message) {
    errorMessage = message;
    status = PresenterRemoteConnectionStatus.error;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(disconnect(notify: false));
    super.dispose();
  }
}
