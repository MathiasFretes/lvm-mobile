import 'package:flutter/material.dart';
import 'package:lvm_api/lvm_api.dart';
import 'package:lvm_design/lvm_design.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_persistence/lvm_persistence.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'presenter_remote_connection.dart';
import 'remote_dashboard.dart';

void main() {
  runApp(const LvmPresenterRemoteApp());
}

class LvmPresenterRemoteApp extends StatefulWidget {
  const LvmPresenterRemoteApp({super.key});

  @override
  State<LvmPresenterRemoteApp> createState() => _LvmPresenterRemoteAppState();
}

class _LvmPresenterRemoteAppState extends State<LvmPresenterRemoteApp> {
  final _theme = LvmThemeController();
  final _connection = PresenterRemoteConnection();

  @override
  void dispose() {
    _theme.dispose();
    _connection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = LvmProduct.presenterRemote;
    return ListenableBuilder(
      listenable: _theme,
      builder: (context, _) {
        return MaterialApp(
          title: product.name,
          debugShowCheckedModeBanner: false,
          theme: LvmTheme.light(),
          darkTheme: LvmTheme.dark(),
          themeMode: _theme.themeMode,
          home: _PresenterRemoteShell(
            productName: product.name,
            connection: _connection,
            theme: _theme,
          ),
        );
      },
    );
  }
}

class _PresenterRemoteShell extends StatefulWidget {
  const _PresenterRemoteShell({
    required this.productName,
    required this.connection,
    required this.theme,
  });

  final String productName;
  final PresenterRemoteConnection connection;
  final LvmThemeController theme;

  @override
  State<_PresenterRemoteShell> createState() => _PresenterRemoteShellState();
}

class _PresenterRemoteShellState extends State<_PresenterRemoteShell> {
  var _index = 0;

  static const _titles = [
    'Control',
    'Culto',
    'Biblia',
    'Canciones',
    'Conexión',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      RemoteControlPage(
        connection: widget.connection,
        onOpenConnection: () => setState(() => _index = 4),
      ),
      ServiceOrderPage(
        connection: widget.connection,
        onOpenTeam: () =>
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TeamPage())),
      ),
      BiblePage(connection: widget.connection),
      const SongLibraryPage(),
      PresenterRemoteConnectionPage(
        connection: widget.connection,
        theme: widget.theme,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('${widget.productName} · ${_titles[_index]}')),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.playlist_play_outlined),
            label: 'Culto',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            label: 'Biblia',
          ),
          NavigationDestination(
            icon: Icon(Icons.music_note_outlined),
            label: 'Canciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.wifi_outlined),
            label: 'Conexión',
          ),
        ],
      ),
    );
  }
}

class PresenterRemoteConnectionPage extends StatefulWidget {
  const PresenterRemoteConnectionPage({
    super.key,
    required this.connection,
    required this.theme,
  });

  final PresenterRemoteConnection connection;
  final LvmThemeController theme;

  @override
  State<PresenterRemoteConnectionPage> createState() =>
      _PresenterRemoteConnectionPageState();
}

class _PresenterRemoteConnectionPageState
    extends State<PresenterRemoteConnectionPage> {
  final _link = TextEditingController();

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  void _connect() {
    try {
      final pairing = PresenterRemotePairingLink.parse(_link.text);
      widget.connection.connect(pairing);
    } on FormatException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El enlace de Presenter no es válido.')),
      );
    }
  }

  Future<void> _scanQrCode() async {
    final pairingLink = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _PresenterRemoteQrScannerPage()),
    );
    if (!mounted || pairingLink == null) return;

    _link.text = pairingLink;
    _connect();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.connection,
      builder: (context, _) {
        final connection = widget.connection;
        final isConnected =
            connection.status == PresenterRemoteConnectionStatus.connected;
        final snapshot = connection.snapshot;
        final hasSlide = (snapshot?.slideCount ?? 0) > 0;
        final canBlackout = snapshot?.isLive == true && !snapshot!.isCleared;
        final canRestore = snapshot?.isCleared == true;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Conectar a Presenter',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Escaneá el código QR que genera LVM Presenter o pegá su enlace. La conexión queda dentro de tu red local.',
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              key: const Key('scan-presenter-qr'),
              onPressed: _scanQrCode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Escanear código QR'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _link,
              autocorrect: false,
              enableSuggestions: false,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enlace de emparejamiento',
                hintText: 'lvm-presenter://remote/0.1?...',
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('connect-presenter'),
              onPressed:
                  connection.status ==
                      PresenterRemoteConnectionStatus.connecting
                  ? null
                  : _connect,
              icon: const Icon(Icons.link),
              label: const Text('Solicitar conexión'),
            ),
            const SizedBox(height: 24),
            _RemoteStatus(connection: connection),
            if (snapshot != null) ...[
              const SizedBox(height: 24),
              Text(
                snapshot.showTitle ?? 'Sin presentación activa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                snapshot.slideIndex == null
                    ? 'Sin diapositiva seleccionada'
                    : 'Diapositiva ${snapshot.slideIndex! + 1} de ${snapshot.slideCount}',
              ),
            ],
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  onPressed: isConnected && hasSlide
                      ? () => connection.sendCommand('previous')
                      : null,
                  icon: const Icon(Icons.skip_previous),
                  label: const Text('Anterior'),
                ),
                FilledButton.icon(
                  onPressed: isConnected && hasSlide
                      ? () => connection.sendCommand('next')
                      : null,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Siguiente'),
                ),
                OutlinedButton.icon(
                  onPressed: isConnected && canBlackout
                      ? () => connection.sendCommand('clear')
                      : null,
                  icon: const Icon(Icons.visibility_off_outlined),
                  label: const Text('Blackout'),
                ),
                OutlinedButton.icon(
                  onPressed: isConnected && canRestore
                      ? () => connection.sendCommand('restore')
                      : null,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Restaurar'),
                ),
              ],
            ),
            if (connection.status !=
                PresenterRemoteConnectionStatus.disconnected) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: connection.disconnect,
                child: const Text('Desconectar'),
              ),
            ],
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.contrast_outlined),
              title: const Text('Apariencia'),
              subtitle: const Text('Claro, oscuro o automático'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Apariencia')),
                    body: LvmAppearancePage(controller: widget.theme),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PresenterRemoteQrScannerPage extends StatefulWidget {
  const _PresenterRemoteQrScannerPage();

  @override
  State<_PresenterRemoteQrScannerPage> createState() =>
      _PresenterRemoteQrScannerPageState();
}

class _PresenterRemoteQrScannerPageState
    extends State<_PresenterRemoteQrScannerPage> {
  final _scanner = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  var _handledResult = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handledResult) return;

    String? value;
    for (final barcode in capture.barcodes) {
      final candidate = barcode.rawValue?.trim();
      if (candidate != null && candidate.isNotEmpty) {
        value = candidate;
        break;
      }
    }
    if (value == null) return;

    _handledResult = true;
    await _scanner.stop();
    if (mounted) Navigator.of(context).pop(value);
  }

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR de Presenter')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scanner,
            onDetect: _onDetect,
            errorBuilder: (context, error) => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No se pudo acceder a la cámara. Permití el acceso a cámara o pegá el enlace manualmente.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              minimum: EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Enfocá el código QR mostrado en LVM Presenter.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoteStatus extends StatelessWidget {
  const _RemoteStatus({required this.connection});

  final PresenterRemoteConnection connection;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (connection.status) {
      PresenterRemoteConnectionStatus.disconnected => (
        'Sin conexión',
        Icons.link_off,
      ),
      PresenterRemoteConnectionStatus.connecting => (
        'Conectando con Presenter…',
        Icons.sync,
      ),
      PresenterRemoteConnectionStatus.waitingForApproval => (
        'Esperando aprobación en Presenter',
        Icons.hourglass_top,
      ),
      PresenterRemoteConnectionStatus.connected => (
        'Conectado a Presenter',
        Icons.verified,
      ),
      PresenterRemoteConnectionStatus.error => (
        connection.errorMessage ?? 'No se pudo conectar.',
        Icons.error_outline,
      ),
    };
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon),
      title: Text(label),
    );
  }
}

@visibleForTesting
bool lvmPresenterRemoteBoundariesReady() {
  return const LvmApiBoundary().isConfigured ||
      const UnimplementedLvmStore().isAvailable;
}
