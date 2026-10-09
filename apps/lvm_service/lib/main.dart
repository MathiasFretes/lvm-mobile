import 'package:flutter/material.dart';
import 'package:lvm_api/lvm_api.dart';
import 'package:lvm_design/lvm_design.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_persistence/lvm_persistence.dart';

import 'service_preview.dart';
import 'service_preview_page.dart';

void main() {
  runApp(const LvmServiceApp());
}

class LvmServiceApp extends StatefulWidget {
  const LvmServiceApp({super.key, this.previewController});

  final ServicePreviewController? previewController;

  @override
  State<LvmServiceApp> createState() => _LvmServiceAppState();
}

class _LvmServiceAppState extends State<LvmServiceApp> {
  final _theme = LvmThemeController();
  late final ServicePreviewController _preview =
      widget.previewController ??
      ServicePreviewController(
        storage: DeviceServicePreviewStorage(),
        pickFile: pickServiceJson,
      );

  @override
  void initState() {
    super.initState();
    _preview.load();
  }

  @override
  void dispose() {
    _theme.dispose();
    if (widget.previewController == null) _preview.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = LvmProduct.service;
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
              LvmDestination(
                label: 'Cultos',
                icon: Icons.event_outlined,
                page: ServicePreviewPage(controller: _preview),
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
bool lvmServiceBoundariesReady() {
  return const LvmApiBoundary().isConfigured ||
      const UnimplementedLvmStore().isAvailable;
}
