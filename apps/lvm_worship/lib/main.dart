import 'package:flutter/material.dart';
import 'package:lvm_api/lvm_api.dart';
import 'package:lvm_design/lvm_design.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_persistence/lvm_persistence.dart';

import 'worship_context_preview.dart';
import 'worship_plan_draft.dart';
import 'worship_plan_page.dart';

void main() {
  runApp(const LvmWorshipApp());
}

class LvmWorshipApp extends StatefulWidget {
  const LvmWorshipApp({super.key, this.contextController, this.planController});

  final WorshipContextController? contextController;
  final WorshipPlanController? planController;

  @override
  State<LvmWorshipApp> createState() => _LvmWorshipAppState();
}

class _LvmWorshipAppState extends State<LvmWorshipApp> {
  final _theme = LvmThemeController();
  late final WorshipContextController _context =
      widget.contextController ??
      WorshipContextController(
        storage: DeviceWorshipContextStorage(),
        pickFile: pickWorshipContextJson,
      );
  late final WorshipPlanController _plan =
      widget.planController ??
      WorshipPlanController(
        storage: DeviceWorshipPlanStorage(),
        sharePlan: shareWorshipPlan,
      );

  @override
  void initState() {
    super.initState();
    _context.load();
  }

  @override
  void dispose() {
    _theme.dispose();
    if (widget.contextController == null) _context.dispose();
    if (widget.planController == null) _plan.dispose();
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
              LvmDestination(
                label: 'Repertorio',
                icon: Icons.music_note_outlined,
                page: WorshipPlanPage(
                  contextController: _context,
                  planController: _plan,
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
