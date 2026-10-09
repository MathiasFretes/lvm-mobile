import 'package:flutter/material.dart';
import 'package:lvm_api/lvm_api.dart';
import 'package:lvm_design/lvm_design.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_persistence/lvm_persistence.dart';

void main() {
  runApp(const LvmWorshipApp());
}

class LvmWorshipApp extends StatefulWidget {
  const LvmWorshipApp({super.key});

  @override
  State<LvmWorshipApp> createState() => _LvmWorshipAppState();
}

class _LvmWorshipAppState extends State<LvmWorshipApp> {
  final _theme = LvmThemeController();

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = LvmProduct.worship;
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
              const LvmDestination(
                label: 'Canciones',
                icon: Icons.music_note_outlined,
                page: LvmSectionPage(
                  title: 'Canciones',
                  message:
                      'Esta sección todavía no abre canciones ni repertorios.',
                ),
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

@visibleForTesting
bool lvmWorshipBoundariesReady() {
  return const LvmApiBoundary().isConfigured ||
      const UnimplementedLvmStore().isAvailable;
}
