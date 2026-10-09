import 'package:flutter/material.dart';
import 'package:lvm_api/lvm_api.dart';
import 'package:lvm_design/lvm_design.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_persistence/lvm_persistence.dart';

import 'public_content.dart';
import 'public_content_page.dart';

void main() {
  runApp(const LvmPublicApp());
}

class LvmPublicApp extends StatefulWidget {
  const LvmPublicApp({super.key, this.contentController});

  final PublicContentController? contentController;

  @override
  State<LvmPublicApp> createState() => _LvmPublicAppState();
}

class _LvmPublicAppState extends State<LvmPublicApp> {
  final _theme = LvmThemeController();
  late final PublicContentController _content =
      widget.contentController ??
      PublicContentController(
        storage: DevicePublicContentStorage(),
        pickFile: pickPublicContentJson,
      );

  @override
  void initState() {
    super.initState();
    _content.load();
  }

  @override
  void dispose() {
    _theme.dispose();
    if (widget.contentController == null) _content.dispose();
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
                page: PublicContentPage(
                  controller: _content,
                  section: PublicContentSection.home,
                ),
              ),
              LvmDestination(
                label: 'Eventos',
                icon: Icons.event_outlined,
                page: PublicContentPage(
                  controller: _content,
                  section: PublicContentSection.events,
                ),
              ),
              LvmDestination(
                label: 'Prédicas',
                icon: Icons.menu_book_outlined,
                page: PublicContentPage(
                  controller: _content,
                  section: PublicContentSection.sermons,
                ),
              ),
              LvmDestination(
                label: 'Sedes',
                icon: Icons.place_outlined,
                page: PublicContentPage(
                  controller: _content,
                  section: PublicContentSection.venues,
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
