import 'package:flutter/material.dart';
import 'package:lvm_api/lvm_api.dart';
import 'package:lvm_design/lvm_design.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_persistence/lvm_persistence.dart';

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

  @override
  void dispose() {
    _theme.dispose();
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
              const LvmDestination(
                label: 'Conexión',
                icon: Icons.wifi_outlined,
                page: LvmSectionPage(
                  title: 'Conexión',
                  message:
                      'Esta sección todavía no busca LVM Presenter ni abre un puerto.',
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
bool lvmPresenterRemoteBoundariesReady() {
  return const LvmApiBoundary().isConfigured ||
      const UnimplementedLvmStore().isAvailable;
}
