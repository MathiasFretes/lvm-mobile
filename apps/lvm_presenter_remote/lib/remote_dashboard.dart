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
          return _RemoteEmptyState(
            connection: connection,
            onOpenConnection: widget.onOpenConnection,
          );
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
  const _RemoteEmptyState({
    required this.connection,
    required this.onOpenConnection,
  });

  final PresenterRemoteConnection connection;
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
              _titleFor(connection),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(_detailFor(connection), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onOpenConnection,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(_actionFor(connection)),
            ),
          ],
        ),
      ),
    );
  }

  static String _titleFor(PresenterRemoteConnection connection) =>
      switch (connection.status) {
        PresenterRemoteConnectionStatus.connecting =>
          'Conectando con Presenter',
        PresenterRemoteConnectionStatus.waitingForApproval =>
          'Esperando aprobación',
        PresenterRemoteConnectionStatus.error => 'No se pudo conectar',
        _ => 'Sin conexión',
      };

  static String _detailFor(PresenterRemoteConnection connection) =>
      switch (connection.status) {
        PresenterRemoteConnectionStatus.connecting =>
          'Estamos abriendo la conexión segura con Presenter.',
        PresenterRemoteConnectionStatus.waitingForApproval =>
          'Aprobá esta solicitud en LVM Presenter para habilitar el control.',
        PresenterRemoteConnectionStatus.error =>
          connection.errorMessage ??
              'Revisá el QR y que ambos equipos estén en la misma red local.',
        _ => 'Escaneá el QR de LVM Presenter para controlar la presentación desde esta red local.',
      };

  static String _actionFor(PresenterRemoteConnection connection) =>
      connection.status == PresenterRemoteConnectionStatus.error
      ? 'Intentar nuevamente'
      : 'Conectar a Presenter';
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
    final currentSlide = snapshot?.slideIndex;
    final slideCount = snapshot?.slideCount ?? 0;
    final canGoPrevious = currentSlide != null && currentSlide > 0;
    final canGoNext = currentSlide != null && currentSlide < slideCount - 1;
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
                    onPressed: canGoPrevious
                        ? () => connection.sendCommand('previous')
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Anterior'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: canGoNext
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
        final connected =
            connection.status == PresenterRemoteConnectionStatus.connected;
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
                        onTap: connected
                            ? () => connection.sendCommand(
                                'goTo',
                                slideIndex: index,
                              )
                            : null,
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
  const BiblePage({super.key, required this.connection});

  final PresenterRemoteConnection connection;

  @override
  State<BiblePage> createState() => _BiblePageState();
}

class _BiblePageState extends State<BiblePage> {
  var _listView = true;
  var _selected = 0;
  static const _verseCount = 4;
  static const _books = <String>[
    'Génesis',
    'Éxodo',
    'Levítico',
    'Números',
    'Deuteronomio',
    'Josué',
    'Jueces',
    'Rut',
    '1 Samuel',
    '2 Samuel',
    '1 Reyes',
    '2 Reyes',
    '1 Crónicas',
    '2 Crónicas',
    'Esdras',
    'Nehemías',
    'Ester',
    'Job',
    'Salmos',
    'Proverbios',
    'Eclesiastés',
    'Cantares',
    'Isaías',
    'Jeremías',
    'Lamentaciones',
    'Ezequiel',
    'Daniel',
    'Oseas',
    'Joel',
    'Amós',
    'Abdías',
    'Jonás',
    'Miqueas',
    'Nahúm',
    'Habacuc',
    'Sofonías',
    'Hageo',
    'Zacarías',
    'Malaquías',
    'Mateo',
    'Marcos',
    'Lucas',
    'Juan',
    'Hechos',
    'Romanos',
    '1 Corintios',
    '2 Corintios',
    'Gálatas',
    'Efesios',
    'Filipenses',
    'Colosenses',
    '1 Tesalonicenses',
    '2 Tesalonicenses',
    '1 Timoteo',
    '2 Timoteo',
    'Tito',
    'Filemón',
    'Hebreos',
    'Santiago',
    '1 Pedro',
    '2 Pedro',
    '1 Juan',
    '2 Juan',
    '3 Juan',
    'Judas',
    'Apocalipsis',
  ];
  var _book = 19;
  var _chapter = '23';
  var _verse = '1';

  void _presentReference() {
    final chapter = int.tryParse(_chapter);
    final verse = int.tryParse(_verse);
    if (chapter == null || chapter < 1 || verse == null || verse < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresá un capítulo y versículo válidos.'),
        ),
      );
      return;
    }
    widget.connection.sendCommand(
      'scripture',
      reference: '$_book.$chapter.$verse',
    );
  }

  void _presentVerse(int index) {
    setState(() => _selected = index);
    widget.connection.sendCommand('scripture', reference: '19.23.${index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.connection,
      builder: (context, _) {
        final connected =
            widget.connection.status ==
            PresenterRemoteConnectionStatus.connected;
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
                    _listView
                        ? Icons.grid_view_outlined
                        : Icons.view_list_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      initialValue: _book,
                      decoration: const InputDecoration(labelText: 'Libro'),
                      items: [
                        for (var index = 0; index < _books.length; index++)
                          DropdownMenuItem(
                            value: index + 1,
                            child: Text(_books[index]),
                          ),
                      ],
                      onChanged: connected
                          ? (value) => setState(() => _book = value ?? _book)
                          : null,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _chapter,
                            decoration: const InputDecoration(
                              labelText: 'Capítulo',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: connected,
                            onChanged: (value) => _chapter = value,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: _verse,
                            decoration: const InputDecoration(
                              labelText: 'Versículo',
                            ),
                            keyboardType: TextInputType.number,
                            enabled: connected,
                            onChanged: (value) => _verse = value,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: connected ? _presentReference : null,
                      icon: const Icon(Icons.cast),
                      label: const Text('Presentar versículo'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Card(
              child: ListTile(
                leading: Icon(Icons.menu_book_outlined),
                title: Text('Salmo 23'),
                subtitle: Text(
                  'Vista rápida · Presenter proyecta el texto de su Biblia activa',
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_listView)
              Card(
                child: Column(
                  children: [
                    for (var index = 0; index < _verseCount; index++)
                      ListTile(
                        selected: _selected == index,
                        leading: Text('${index + 1}'),
                        title: Text('Salmo 23:${index + 1}'),
                        trailing: Icon(
                          connected
                              ? Icons.play_arrow_outlined
                              : Icons.link_off_outlined,
                        ),
                        onTap: connected ? () => _presentVerse(index) : null,
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
                itemCount: _verseCount,
                itemBuilder: (context, index) => InkWell(
                  onTap: connected ? () => _presentVerse(index) : null,
                  child: Card(
                    color: _selected == index
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('Salmo 23:${index + 1}'),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _MessageCard(
              icon: connected ? Icons.cast_connected : Icons.link_off_outlined,
              title: connected
                  ? 'Control bíblico activo'
                  : 'Conectá LVM Presenter',
              detail: connected
                  ? 'Tocá un versículo para presentarlo inmediatamente en la salida activa.'
                  : 'La Biblia se habilita después de emparejar y aprobar este dispositivo.',
            ),
          ],
        );
      },
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
