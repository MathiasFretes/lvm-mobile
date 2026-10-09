import 'package:flutter/material.dart';
import 'package:lvm_api/lvm_api.dart';
import 'package:lvm_design/lvm_design.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_persistence/lvm_persistence.dart';

void main() {
  runApp(const LvmPublicApp());
}

class LvmPublicApp extends StatefulWidget {
  const LvmPublicApp({super.key});

  @override
  State<LvmPublicApp> createState() => _LvmPublicAppState();
}

class _LvmPublicAppState extends State<LvmPublicApp> {
  final _theme = LvmThemeController();

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = LvmProduct.congregacion;
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
                label: 'Visitas',
                icon: Icons.groups_outlined,
                page: LvmSectionPage(
                  title: 'Visitas',
                  message:
                      'Esta sección todavía no consulta contenidos públicos.',
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
bool lvmPublicBoundariesReady() {
  return const LvmApiBoundary().isConfigured ||
      const UnimplementedLvmStore().isAvailable;
}
