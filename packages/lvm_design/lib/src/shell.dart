import 'package:flutter/material.dart';

import 'emblem.dart';
import 'theme.dart';

class LvmDestination {
  const LvmDestination({
    required this.label,
    required this.icon,
    required this.page,
  });

  final String label;
  final IconData icon;
  final Widget page;
}

class LvmAppShell extends StatefulWidget {
  const LvmAppShell({
    super.key,
    required this.title,
    required this.destinations,
  }) : assert(destinations.length > 0);

  final String title;
  final List<LvmDestination> destinations;

  @override
  State<LvmAppShell> createState() => _LvmAppShellState();
}

class _LvmAppShellState extends State<LvmAppShell> {
  var _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: IndexedStack(
        index: _index,
        children: [for (final item in widget.destinations) item.page],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: [
          for (final item in widget.destinations)
            NavigationDestination(icon: Icon(item.icon), label: item.label),
        ],
        onDestinationSelected: (index) => setState(() => _index = index),
      ),
    );
  }
}

class LvmIdentityPage extends StatelessWidget {
  const LvmIdentityPage({
    super.key,
    required this.productName,
    required this.role,
    required this.applicationId,
  });

  final String productName;
  final String role;
  final String applicationId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Center(child: LvmEmblem()),
        const SizedBox(height: 24),
        Text(productName, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(role, style: theme.textTheme.titleMedium),
        const SizedBox(height: 24),
        Text('Identificador Android', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(applicationId, key: const Key('application-id')),
        const SizedBox(height: 24),
        Text(
          'Esta aplicación todavía no consulta servicios ni guarda datos.',
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class LvmSectionPage extends StatelessWidget {
  const LvmSectionPage({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Text(message),
      ],
    );
  }
}

class LvmAppearancePage extends StatelessWidget {
  const LvmAppearancePage({super.key, required this.controller});

  final LvmThemeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Apariencia', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Claro, oscuro o el tema del sistema.'),
            const SizedBox(height: 16),
            SegmentedButton<LvmThemePreference>(
              segments: const [
                ButtonSegment(
                  value: LvmThemePreference.light,
                  label: Text('Claro'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: LvmThemePreference.dark,
                  label: Text('Oscuro'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: LvmThemePreference.system,
                  label: Text('Automático'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
              ],
              selected: {controller.preference},
              onSelectionChanged: (selection) {
                controller.preference = selection.single;
              },
            ),
          ],
        );
      },
    );
  }
}
