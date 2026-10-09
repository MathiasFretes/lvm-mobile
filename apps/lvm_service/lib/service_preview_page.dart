import 'package:flutter/material.dart';

import 'service_preview.dart';

class ServicePreviewPage extends StatelessWidget {
  const ServicePreviewPage({super.key, required this.controller});

  final ServicePreviewController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) {
      final theme = Theme.of(context);
      final service = controller.service;
      final localStart = service?.startsAt.toLocal();
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Cultos', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 8),
          const Text(
            'Vista local de un Service 0.1. No sincroniza con la API.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: controller.loading ? null : controller.importFile,
            icon: const Icon(Icons.file_open_outlined),
            label: const Text('Abrir Service 0.1'),
          ),
          if (service != null)
            TextButton.icon(
              onPressed: controller.clear,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Quitar archivo local'),
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
          if (service == null && !controller.loading)
            const Text(
              'Todavía no hay un culto importado en este dispositivo.',
            ),
          if (service != null) ...[
            Text(service.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${MaterialLocalizations.of(context).formatMediumDate(localStart!)} '
              '· ${TimeOfDay.fromDateTime(localStart).format(context)} '
              '· ${service.setlistName}',
            ),
            const SizedBox(height: 16),
            for (var index = 0; index < service.items.length; index++)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(service.items[index].title),
                  subtitle: Text(
                    service.items[index].detail.isEmpty
                        ? _kindLabel(service.items[index].kind)
                        : '${_kindLabel(service.items[index].kind)} · ${service.items[index].detail}',
                  ),
                ),
              ),
          ],
        ],
      );
    },
  );
}

String _kindLabel(String kind) => switch (kind) {
  'SONG' => 'Canción',
  'SCRIPTURE' => 'Biblia',
  'ANNOUNCEMENT' => 'Anuncio',
  'SERMON' => 'Predicación',
  _ => kind,
};
