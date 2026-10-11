import 'package:flutter/material.dart';
import 'package:lvm_models/lvm_models.dart';

import 'worship_context_preview.dart';
import 'worship_plan_draft.dart';

class WorshipPlanPage extends StatefulWidget {
  const WorshipPlanPage({
    super.key,
    required this.contextController,
    required this.planController,
  });

  final WorshipContextController contextController;
  final WorshipPlanController planController;

  @override
  State<WorshipPlanPage> createState() => _WorshipPlanPageState();
}

class _WorshipPlanPageState extends State<WorshipPlanPage> {
  String? _requestedServiceId;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: Listenable.merge([
      widget.contextController,
      widget.planController,
    ]),
    builder: (context, _) {
      final handoff = widget.contextController.context;
      if (handoff == null) {
        if (_requestedServiceId != null) {
          _requestedServiceId = null;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.planController.reset(),
          );
        }
        return _NoContext(controller: widget.contextController);
      }
      if (_requestedServiceId != handoff.serviceId) {
        _requestedServiceId = handoff.serviceId;
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.planController.load(handoff),
        );
      }
      return _PlanBody(
        handoff: handoff,
        controller: widget.planController,
        contextController: widget.contextController,
      );
    },
  );
}

class _NoContext extends StatelessWidget {
  const _NoContext({required this.controller});

  final WorshipContextController controller;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('Repertorio', style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      const Text(
        'Abrí el contexto que exportó LVM Service para preparar el repertorio local.',
      ),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: controller.loading ? null : controller.importFile,
        icon: const Icon(Icons.file_open_outlined),
        label: const Text('Abrir WorshipContext 0.1'),
      ),
      if (controller.error != null) ...[
        const SizedBox(height: 12),
        Text(
          controller.error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ],
    ],
  );
}

class _PlanBody extends StatelessWidget {
  const _PlanBody({
    required this.handoff,
    required this.controller,
    required this.contextController,
  });

  final WorshipContextDocument handoff;
  final WorshipPlanController controller;
  final WorshipContextController contextController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final songs = controller.plan?.songs ?? const <WorshipPlanSong>[];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Repertorio', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(handoff.title, style: theme.textTheme.titleMedium),
        Text(handoff.name, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(_localDateTime(handoff.startsAt.toLocal())),
        const SizedBox(height: 16),
        if (controller.loading) const LinearProgressIndicator(),
        if (controller.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              controller.error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        if (!controller.loading && songs.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Todavía no agregaste canciones a este repertorio.'),
            ),
          ),
        if (songs.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: songs.length,
            onReorderItem: (oldIndex, newIndex) =>
                controller.moveSong(handoff, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final song = songs[index];
              return Card(
                key: ValueKey('${song.songId}-$index'),
                child: ListTile(
                  leading: Text('${index + 1}'),
                  title: Text(song.title),
                  subtitle: Text(
                    '${song.key} · ${song.sections.length} secciones',
                  ),
                  trailing: IconButton(
                    tooltip: 'Quitar canción',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => controller.removeSong(handoff, index),
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: controller.loading
              ? null
              : () async {
                  final song = await showDialog<WorshipPlanSong>(
                    context: context,
                    builder: (_) => const _SongDialog(),
                  );
                  if (song != null && context.mounted) {
                    await controller.addSong(handoff, song);
                  }
                },
          icon: const Icon(Icons.add),
          label: const Text('Agregar canción'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: songs.isEmpty || controller.loading
              ? null
              : () => controller.share(handoff),
          icon: const Icon(Icons.ios_share_outlined),
          label: const Text('Compartir WorshipPlan 0.1'),
        ),
        TextButton.icon(
          onPressed: contextController.loading
              ? null
              : contextController.importFile,
          icon: const Icon(Icons.refresh_outlined),
          label: const Text('Cambiar contexto'),
        ),
      ],
    );
  }
}

class _SongDialog extends StatefulWidget {
  const _SongDialog();

  @override
  State<_SongDialog> createState() => _SongDialogState();
}

class _SongDialogState extends State<_SongDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _key = TextEditingController(text: 'C');
  final _section = TextEditingController(text: 'Verso');
  final _lyrics = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _key.dispose();
    _section.dispose();
    _lyrics.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Agregar canción'),
    content: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Título'),
              validator: _required,
            ),
            TextFormField(
              controller: _key,
              decoration: const InputDecoration(labelText: 'Tonalidad'),
            ),
            TextFormField(
              controller: _section,
              decoration: const InputDecoration(labelText: 'Sección'),
              validator: _required,
            ),
            TextFormField(
              controller: _lyrics,
              decoration: const InputDecoration(labelText: 'Letra'),
              minLines: 3,
              maxLines: 8,
              validator: _required,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (!(_formKey.currentState?.validate() ?? false)) return;
          final title = _title.text.trim();
          final section = _section.text.trim();
          final lines = _lyrics.text
              .split(RegExp(r'\r?\n'))
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .map((line) => WorshipPlanLine(text: line, chords: const []))
              .toList(growable: false);
          Navigator.pop(
            context,
            WorshipPlanSong(
              songId: _songId(title),
              title: title,
              key: _key.text.trim(),
              arrangement: const [1],
              sections: [
                WorshipPlanSection(kind: 'verse', label: section, lines: lines),
              ],
            ),
          );
        },
        child: const Text('Guardar'),
      ),
    ],
  );
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'Completá este campo.' : null;

String _songId(String title) => title
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '')
    .ifEmpty('cancion');

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}

String _localDateTime(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} '
      '${two(value.hour)}:${two(value.minute)}';
}
