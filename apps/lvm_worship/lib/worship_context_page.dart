import 'package:flutter/material.dart';

import 'worship_context_preview.dart';

class WorshipContextPage extends StatelessWidget {
  const WorshipContextPage({super.key, required this.controller});

  final WorshipContextController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final theme = Theme.of(context);
      final handoff = controller.context;
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Repertorio', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text(
            'Abrí un contexto exportado por LVM Service para preparar la música sin conexión.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: controller.loading ? null : controller.importFile,
            icon: const Icon(Icons.file_open_outlined),
            label: const Text('Abrir WorshipContext 0.1'),
          ),
          if (handoff != null)
            TextButton.icon(
              onPressed: controller.clear,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Quitar contexto local'),
            ),
          const SizedBox(height: 16),
          if (controller.loading) const LinearProgressIndicator(),
          if (controller.error != null)
            Semantics(
              liveRegion: true,
              child: Text(
                controller.error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          if (handoff == null && !controller.loading)
            const Text('Todavía no hay un culto recibido en este dispositivo.'),
          if (handoff != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(handoff.title, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(_localDateTime(handoff.startsAt.toLocal())),
                    const SizedBox(height: 16),
                    Text('Repertorio', style: theme.textTheme.labelLarge),
                    Text(handoff.name),
                    const SizedBox(height: 16),
                    Text(
                      'Contexto recibido · preparación local',
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'La edición de canciones y la exportación de WorshipPlan se incorporarán en el siguiente slice.',
            ),
          ],
        ],
      );
    },
  );
}

String _localDateTime(DateTime value) {
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} '
      '${two(value.hour)}:${two(value.minute)}';
}
