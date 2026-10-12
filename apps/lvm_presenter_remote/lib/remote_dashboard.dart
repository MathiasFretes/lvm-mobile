import 'package:flutter/material.dart';

import 'presenter_remote_connection.dart';

class RemoteControlPage extends StatefulWidget {
  const RemoteControlPage({
    super.key,
    required this.connection,
    required this.onOpenConnection,
  });

  final PresenterRemoteConnection connection;
  final VoidCallback onOpenConnection;

  @override
  State<RemoteControlPage> createState() => _RemoteControlPageState();
}

class _RemoteControlPageState extends State<RemoteControlPage> {
  var _interface = 'Presentación principal';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.connection,
      builder: (context, _) {
        final connection = widget.connection;
        final connected =
            connection.status == PresenterRemoteConnectionStatus.connected;
        final snapshot = connection.snapshot;

        if (!connected) {
          return _RemoteEmptyState(onOpenConnection: widget.onOpenConnection);
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Icon(Icons.wifi, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Conectado a Presenter',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Desconectar',
                  onPressed: connection.disconnect,
                  icon: const Icon(Icons.link_off),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _interface,
              decoration: const InputDecoration(
                labelText: 'Interfaz de control',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Presentación principal',
                  child: Text('Presentación principal'),
                ),
                DropdownMenuItem(
                  value: 'Escenario',
                  enabled: false,
                  child: Text('Escenario · próximamente'),
                ),
                DropdownMenuItem(
                  value: 'Letras',
                  enabled: false,
                  child: Text('Letras · próximamente'),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _interface = value);
              },
            ),
            const SizedBox(height: 16),
            _OutputPreview(snapshot: snapshot),
            const SizedBox(height: 16),
            _SlidePosition(snapshot: snapshot),
            const SizedBox(height: 20),
            _ControlPad(connection: connection, snapshot: snapshot),
            const SizedBox(height: 24),
            Text(
              'Ir a diapositiva',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            _SlidePicker(connection: connection, snapshot: snapshot),
          ],
        );
      },
    );
  }
}

class _RemoteEmptyState extends StatelessWidget {
  const _RemoteEmptyState({required this.onOpenConnection});

  final VoidCallback onOpenConnection;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest,
              child: const Icon(Icons.wifi_off_outlined, size: 42),
            ),
            const SizedBox(height: 20),
            Text(
              'Sin conexión',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Escaneá el QR de LVM Presenter para controlar la presentación desde esta red local.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onOpenConnection,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Conectar a Presenter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutputPreview extends StatelessWidget {
  const _OutputPreview({required this.snapshot});

  final PresenterRemoteSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = snapshot?.showTitle ?? 'Sin presentación activa';
    final subtitle = snapshot?.isCleared == true
        ? 'Salida en negro'
        : snapshot?.isLive == true
        ? 'En vivo'
        : 'Vista previa';
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  snapshot?.isCleared == true ? 'BLACKOUT' : title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: Chip(
                avatar: Icon(
                  snapshot?.isCleared == true
                      ? Icons.visibility_off
                      : Icons.circle,
                  size: 14,
                  color: snapshot?.isCleared == true
                      ? Colors.white
                      : Colors.green,
                ),
                label: Text(subtitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlidePosition extends StatelessWidget {
  const _SlidePosition({required this.snapshot});

  final PresenterRemoteSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final current = snapshot?.slideIndex;
    final total = snapshot?.slideCount ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.slideshow_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                current == null
                    ? 'Sin diapositiva seleccionada'
                    : 'Diapositiva ${current + 1} de $total',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlPad extends StatelessWidget {
  const _ControlPad({required this.connection, required this.snapshot});

  final PresenterRemoteConnection connection;
  final PresenterRemoteSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final hasSlide = (snapshot?.slideCount ?? 0) > 0;
    final canBlackout = snapshot?.isLive == true && !snapshot!.isCleared;
    final canRestore = snapshot?.isCleared == true;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: hasSlide
                        ? () => connection.sendCommand('previous')
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: hasSlide
                        ? () => connection.sendCommand('next')
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    label: const Text('Siguiente'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canBlackout
                        ? () => connection.sendCommand('clear')
                        : null,
                    icon: const Icon(Icons.visibility_off_outlined),
                    label: const Text('Blackout'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: canRestore
                        ? () => connection.sendCommand('restore')
                        : null,
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Restaurar salida'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SlidePicker extends StatelessWidget {
  const _SlidePicker({required this.connection, required this.snapshot});

  final PresenterRemoteConnection connection;
  final PresenterRemoteSnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final count = snapshot?.slideCount ?? 0;
    if (count == 0) {
      return const Text(
        'Presenter enviará las diapositivas cuando haya una presentación activa.',
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var index = 0; index < count; index++)
          ChoiceChip(
            label: Text('${index + 1}'),
            selected: snapshot?.slideIndex == index,
            onSelected: (_) =>
                connection.sendCommand('goTo', slideIndex: index),
          ),
      ],
    );
  }
}

class ServiceOrderPage extends StatelessWidget {
  const ServiceOrderPage({
    super.key,
    required this.connection,
    required this.onOpenTeam,
  });

  final PresenterRemoteConnection connection;
  final VoidCallback onOpenTeam;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: connection,
      builder: (context, _) {
        final snapshot = connection.snapshot;
        final total = snapshot?.slideCount ?? 0;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Orden del culto',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              snapshot?.showTitle ??
                  'Conectate para recibir la presentación activa.',
            ),
            const SizedBox(height: 16),
            if (total == 0)
              const _MessageCard(
                icon: Icons.playlist_remove,
                title: 'Sin presentación activa',
                detail: 'Cuando Presenter cargue un culto, aquí aparecerán sus diapositivas para navegar.',
              )
            else
              Card(
                child: Column(
                  children: [
                    for (var index = 0; index < total; index++)
                      ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text('Diapositiva ${index + 1}'),
                        subtitle: Text(
                          index == snapshot?.slideIndex
                              ? 'En pantalla'
                              : 'Tocar para presentar',
                        ),
                        selected: index == snapshot?.slideIndex,
                        trailing: const Icon(Icons.play_arrow_outlined),
                        onTap: () =>
                            connection.sendCommand('goTo', slideIndex: index),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              leading: const Icon(Icons.groups_outlined),
              title: const Text('Equipo del culto'),
              subtitle: const Text('Integrantes e instrumentos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: onOpenTeam,
            ),
          ],
        );
      },
    );
  }
}

class BiblePage extends StatefulWidget {
  const BiblePage({super.key});

  @override
  State<BiblePage> createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  var _listView = true;
  var _selected = 0;
  static const _verses = [
    'El Señor es mi pastor; nada me faltará.',
    'En lugares de delicados pastos me hará descansar.',
    'Junto a aguas de reposo me pastoreará.',
    'Confortará mi alma; me guiará por sendas de justicia.',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Biblia',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            IconButton(
              tooltip: _listView ? 'Vista de cuadrícula' : 'Vista de lista',
              onPressed: () => setState(() => _listView = !_listView),
              icon: Icon(
                _listView ? Icons.grid_view_outlined : Icons.view_list_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            leading: Icon(Icons.menu_book_outlined),
            title: Text('Salmo 23'),
            subtitle: Text('Lectura local para la próxima integración bíblica'),
          ),
        ),
        const SizedBox(height: 12),
        if (_listView)
          Card(
            child: Column(
              children: [
                for (var index = 0; index < _verses.length; index++)
                  ListTile(
                    selected: _selected == index,
                    leading: Text('${index + 1}'),
                    title: Text(_verses[index]),
                    onTap: () => setState(() => _selected = index),
                  ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.15,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _verses.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () => setState(() => _selected = index),
              child: Card(
                color: _selected == index
                    ? Theme.of(context).colorScheme.secondaryContainer
                    : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('${index + 1}. ${_verses[index]}'),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        const _MessageCard(
          icon: Icons.info_outline,
          title: 'Control bíblico en preparación',
          detail: 'La selección ya es navegable en la app. Presentarla llegará con el contrato de Biblia de Presenter.',
        ),
      ],
    );
  }
}

class SongLibraryPage extends StatefulWidget {
  const SongLibraryPage({super.key});

  @override
  State<SongLibraryPage> createState() => _SongLibraryPageState();
}

class _SongLibraryPageState extends State<SongLibraryPage> {
  final _search = TextEditingController();
  static const _songs = [
    ('Cantamos con fe', 'La Voz Misionera'),
    ('Señor fiel', 'Repertorio local'),
    ('Gracia', 'Repertorio local'),
    ('Alabanza', 'Repertorio local'),
    ('Digno eres', 'Repertorio local'),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final results = _songs.where(
      (song) =>
          song.$1.toLowerCase().contains(query) ||
          song.$2.toLowerCase().contains(query),
    );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Canciones', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
            labelText: 'Buscar título o artista',
          ),
        ),
        const SizedBox(height: 12),
        for (final song in results)
          Card(
            child: ListTile(
              leading: const Icon(Icons.music_note_outlined),
              title: Text(song.$1),
              subtitle: Text(song.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSong(context, song),
            ),
          ),
        const SizedBox(height: 12),
        const _MessageCard(
          icon: Icons.cloud_off_outlined,
          title: 'Biblioteca local',
          detail: 'Esta vista prepara la búsqueda y selección. La biblioteca real llegará desde LVM Worship sin depender de Internet.',
        ),
      ],
    );
  }

  void _showSong(BuildContext context, (String, String) song) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(song.$1, style: Theme.of(context).textTheme.headlineSmall),
            Text(song.$2),
            const SizedBox(height: 20),
            const Text('Verso · Coro · Verso 2 · Coro · Puente'),
            const SizedBox(height: 12),
            const Text(
              'La letra y acordes reales se cargarán desde el repertorio de Worship.',
            ),
          ],
        ),
      ),
    );
  }
}

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  static const _members = [
    ('Integrante 1', 'Voz principal'),
    ('Integrante 2', 'Guitarra'),
    ('Integrante 3', 'Teclado'),
    ('Integrante 4', 'Batería'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipo del culto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Información local del equipo para esta vista de control.',
          ),
          const SizedBox(height: 16),
          for (final member in _members)
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(member.$1),
                subtitle: Text(member.$2),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(detail),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
