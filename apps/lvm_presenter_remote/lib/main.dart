import 'package:flutter/material.dart';
import 'package:lvm_api/lvm_api.dart';
import 'package:lvm_design/lvm_design.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_persistence/lvm_persistence.dart';

import 'presenter_remote_connection.dart';

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
          home: LvmAppShell(
            title: product.name,
            destinations: [
              LvmDestination(
                label: 'Inicio',
                icon: Icons.home_outlined,
                page: LvmIdentityPage(
                  productName: product.name,
                  role: product.role,
                  applicationId: product.applicationId,
                ),
              ),
              LvmDestination(
                label: 'Conexión',
                icon: Icons.wifi_outlined,
                page: PresenterRemoteConnectionPage(connection: _connection),
              ),
              LvmDestination(
                label: 'Apariencia',
                icon: Icons.contrast_outlined,
                page: LvmAppearancePage(controller: _theme),
              ),
            ],
          ),
        );
      },
    );
  }
}

class PresenterRemoteConnectionPage extends StatefulWidget {
  const PresenterRemoteConnectionPage({super.key, required this.connection});

  final PresenterRemoteConnection connection;

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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.connection,
      builder: (context, _) {
        final connection = widget.connection;
        final isConnected =
            connection.status == PresenterRemoteConnectionStatus.connected;
        final snapshot = connection.snapshot;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Conectar a Presenter',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pegá el enlace que genera LVM Presenter. La conexión queda dentro de tu red local.',
            ),
            const SizedBox(height: 20),
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
                  onPressed: isConnected
                      ? () => connection.sendCommand('previous')
                      : null,
                  icon: const Icon(Icons.skip_previous),
                  label: const Text('Anterior'),
                ),
                FilledButton.icon(
                  onPressed: isConnected
                      ? () => connection.sendCommand('next')
                      : null,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Siguiente'),
                ),
                OutlinedButton.icon(
                  onPressed: isConnected
                      ? () => connection.sendCommand('clear')
                      : null,
                  icon: const Icon(Icons.visibility_off_outlined),
                  label: const Text('Blackout'),
                ),
                OutlinedButton.icon(
                  onPressed: isConnected
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
          ],
        );
      },
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
