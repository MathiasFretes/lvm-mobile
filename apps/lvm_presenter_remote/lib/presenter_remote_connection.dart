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

class PresenterRemoteSlide {
  const PresenterRemoteSlide({required this.index, required this.label});
  final int index;
  final String label;

  factory PresenterRemoteSlide.fromJson(Map<String, dynamic> value) =>
      PresenterRemoteSlide(
        index: value['index'] as int? ?? 0,
        label: value['label'] as String? ?? 'Diapositiva',
      );
}

class PresenterRemoteItem {
  const PresenterRemoteItem({
    required this.index,
    required this.title,
    required this.kind,
    required this.slides,
  });
  final int index;
  final String title;
  final String kind;
  final List<PresenterRemoteSlide> slides;

  factory PresenterRemoteItem.fromJson(Map<String, dynamic> value) =>
      PresenterRemoteItem(
        index: value['index'] as int? ?? 0,
        title: value['title'] as String? ?? 'Elemento',
        kind: value['kind'] as String? ?? 'show',
        slides: (value['slides'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(PresenterRemoteSlide.fromJson)
            .toList(growable: false),
      );
}

class PresenterRemoteSnapshot {
  const PresenterRemoteSnapshot({
    required this.showTitle,
    required this.itemIndex,
    required this.slideIndex,
    required this.slideCount,
    required this.isLive,
    required this.isCleared,
    this.projectTitle,
    this.items = const [],
  });

  final String? showTitle;
  final int? itemIndex;
  final int? slideIndex;
  final int? slideCount;
  final bool isLive;
  final bool isCleared;
  final String? projectTitle;
  final List<PresenterRemoteItem> items;

  factory PresenterRemoteSnapshot.fromMessage(Map<String, Object?> value) {
    final show = value['show'] as Map<String, Object?>?;
    final current = value['current'] as Map<String, Object?>?;
    final output = value['output'] as Map<String, Object?>? ?? const {};
    final project = value['project'] as Map<String, Object?>?;
    return PresenterRemoteSnapshot(
      showTitle: show?['title'] as String?,
      itemIndex: current?['itemIndex'] as int?,
      slideIndex: current?['slideIndex'] as int?,
      slideCount: current?['slideCount'] as int?,
      isLive: output['isLive'] as bool? ?? false,
      isCleared: output['isCleared'] as bool? ?? false,
      projectTitle: project?['title'] as String?,
      items: (value['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PresenterRemoteItem.fromJson)
          .toList(growable: false),
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
          if (status != PresenterRemoteConnectionStatus.disconnected &&
              status != PresenterRemoteConnectionStatus.error) {
            _socket = null;
            _sessionToken = null;
            snapshot = null;
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
      _fail(
        'No se pudo conectar con LVM Presenter. El QR puede haber vencido o pertenecer a otra red. En Presenter, activá Control remoto local y generá un QR nuevo.',
      );
    }
  }

  void sendCommand(
    String command, {
    int? slideIndex,
    int? itemIndex,
    String? reference,
  }) {
    if (status != PresenterRemoteConnectionStatus.connected ||
        _sessionToken == null) {
      return;
    }
    _send({
      'type': 'command.$command',
      'sessionToken': _sessionToken,
      'slideIndex': ?slideIndex,
      'itemIndex': ?itemIndex,
      'reference': ?reference,
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
        case 'command.applied':
          final state = message['state'];
          if (state is Map<String, dynamic>) {
            snapshot = PresenterRemoteSnapshot.fromMessage(
              state.cast<String, Object?>(),
            );
            notifyListeners();
          }
        case 'pair.rejected':
          final code = message['code'];
          _fail(
            code == 'expired_pairing'
                ? 'El QR venció. Generá uno nuevo en Presenter y volvé a escanearlo.'
                : code == 'invalid_pairing'
                ? 'El QR ya se usó o dejó de ser válido. Generá uno nuevo en Presenter y volvé a escanearlo.'
                : 'Presenter rechazó la solicitud de conexión.',
          );
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
    _sessionToken = null;
    snapshot = null;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(disconnect(notify: false));
    super.dispose();
  }
}
