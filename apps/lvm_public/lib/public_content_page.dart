import 'package:flutter/material.dart';
import 'package:lvm_design/lvm_design.dart';
import 'package:lvm_models/lvm_models.dart';

import 'public_content.dart';

class PublicContentPage extends StatelessWidget {
  const PublicContentPage({
    super.key,
    required this.controller,
    required this.section,
  });

  final PublicContentController controller;
  final PublicContentSection section;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final content = controller.content;
        final theme = Theme.of(context);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (section == PublicContentSection.home) ...[
              const Center(child: LvmEmblem()),
              const SizedBox(height: 16),
            ],
            Text(section.title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            const Text(
              'Vista local de un archivo de LVM Service. No está publicada.',
            ),
            const SizedBox(height: 16),
            if (section == PublicContentSection.home) ...[
              FilledButton.icon(
                onPressed: controller.loading ? null : controller.importFile,
                icon: const Icon(Icons.file_open_outlined),
                label: const Text('Abrir PublicContent 0.1'),
              ),
              if (content != null)
                TextButton.icon(
                  onPressed: controller.clear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Quitar archivo local'),
                ),
              const SizedBox(height: 16),
            ],
            if (controller.loading) const LinearProgressIndicator(),
            if (controller.error != null)
              Semantics(
                liveRegion: true,
                child: Text(
                  controller.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            if (content == null && !controller.loading)
              const Text(
                'Todavía no hay contenido importado en este dispositivo.',
              ),
            if (content != null) ...[
              Text(
                'Archivo local · ${content.generatedAt.toUtc().toIso8601String()}',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 16),
              ..._cards(content),
            ],
          ],
        );
      },
    );
  }

  List<Widget> _cards(PublicContent content) {
    switch (section) {
      case PublicContentSection.home:
        return [
          _SummaryCard(label: 'Eventos', count: content.events.length),
          _SummaryCard(label: 'Prédicas', count: content.sermons.length),
          _SummaryCard(label: 'Sedes', count: content.venues.length),
        ];
      case PublicContentSection.events:
        return content.events.isEmpty
            ? [const Text('No hay eventos en este archivo.')]
            : [
                for (final event in content.events)
                  _ItemCard(
                    title: event.title,
                    subtitle: '${event.date} · ${event.time} · ${event.venue}',
                    body: event.description,
                  ),
              ];
      case PublicContentSection.sermons:
        return content.sermons.isEmpty
            ? [const Text('No hay prédicas en este archivo.')]
            : [
                for (final sermon in content.sermons)
                  _ItemCard(
                    title: sermon.title,
                    subtitle:
                        '${sermon.date} · ${sermon.speaker} · ${sermon.series}',
                    body: sermon.summary,
                  ),
              ];
      case PublicContentSection.venues:
        return content.venues.isEmpty
            ? [const Text('No hay sedes en este archivo.')]
            : [
                for (final venue in content.venues)
                  _ItemCard(
                    title: venue.name,
                    subtitle: '${venue.zone} · ${venue.address}',
                    body: venue.hours,
                  ),
              ];
    }
  }
}

enum PublicContentSection {
  home('Inicio'),
  events('Eventos'),
  sermons('Prédicas'),
  venues('Sedes');

  const PublicContentSection(this.title);
  final String title;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(title: Text(label), trailing: Text('$count')),
  );
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({
    required this.title,
    required this.subtitle,
    required this.body,
  });

  final String title;
  final String subtitle;
  final String body;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(subtitle),
          const SizedBox(height: 8),
          Text(body),
        ],
      ),
    ),
  );
}
