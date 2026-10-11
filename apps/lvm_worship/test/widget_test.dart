import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:lvm_worship/main.dart';
import 'package:lvm_worship/worship_context_preview.dart';
import 'package:lvm_worship/worship_plan_draft.dart';

final class _MemoryStorage implements WorshipContextStorage {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String source) async => value = source;

  @override
  Future<void> clear() async => value = null;
}

final class _MemoryPlanStorage implements WorshipPlanStorage {
  final values = <String, String>{};

  @override
  Future<void> clear(String serviceId) async => values.remove(serviceId);

  @override
  Future<String?> read(String serviceId) async => values[serviceId];

  @override
  Future<void> write(String serviceId, String source) async {
    values[serviceId] = source;
  }
}

WorshipPlanController _planController() => WorshipPlanController(
  storage: _MemoryPlanStorage(),
  sharePlan: (_, _) async {},
);

const _context = {
  'schemaVersion': '0.1',
  'serviceId': 'culto-2026-10-18',
  'title': 'Culto General',
  'startsAt': '2026-10-18T19:00:00-03:00',
  'setlistId': 'setlist-culto-2026-10-18',
  'name': 'Adoración',
};

void main() {
  test('keeps the last valid context and restores it after reopen', () async {
    final storage = _MemoryStorage();
    final controller = WorshipContextController(
      storage: storage,
      pickFile: () async => null,
    );
    await controller.importJson(jsonEncode(_context));
    expect(controller.context!.name, 'Adoración');
    await controller.importJson('{broken');
    expect(controller.context!.name, 'Adoración');
    expect(storage.value, jsonEncode(_context));
    final restored = WorshipContextController(
      storage: storage,
      pickFile: () async => null,
    );
    await restored.load();
    expect(restored.context!.title, 'Culto General');
    await restored.clear();
    expect(storage.value, isNull);
  });

  test(
    'saves, reorders and shares a local plan for its imported context',
    () async {
      final storage = _MemoryPlanStorage();
      final shared = <String>[];
      final controller = WorshipPlanController(
        storage: storage,
        sharePlan: (source, fileName) async => shared.add('$fileName:$source'),
      );
      final context = WorshipContextDocument.parse(_context);
      await controller.load(context);
      final song = WorshipPlanSong(
        songId: 'grande-es-el-senor',
        title: 'Grande es el Señor',
        key: 'D',
        arrangement: const [1],
        sections: const [
          WorshipPlanSection(
            kind: 'verse',
            label: 'Verso',
            lines: [WorshipPlanLine(text: 'Grande es el Señor', chords: [])],
          ),
        ],
      );
      await controller.addSong(context, song);
      await controller.addSong(context, song);
      await controller.moveSong(context, 0, 1);
      expect(controller.plan!.songs, hasLength(2));
      expect(storage.values[context.serviceId], isNotNull);
      await controller.share(context);
      expect(shared.single, contains('culto-general-worship-plan.json'));
      await controller.removeSong(context, 1);
      await controller.removeSong(context, 0);
      expect(storage.values, isEmpty);
    },
  );

  testWidgets('imports and shows a WorshipContext from Service', (
    tester,
  ) async {
    final controller = WorshipContextController(
      storage: _MemoryStorage(),
      pickFile: () async => jsonEncode(_context),
    );
    await tester.pumpWidget(
      LvmWorshipApp(
        contextController: controller,
        planController: _planController(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('LVM Worship'), findsWidgets);
    expect(find.byKey(const Key('lvm-emblem')), findsOneWidget);
    expect(lvmWorshipBoundariesReady(), isFalse);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Repertorio'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Abrí el contexto'), findsOneWidget);
    await tester.tap(find.text('Abrir WorshipContext 0.1'));
    await tester.pumpAndSettle();
    expect(find.text('Culto General'), findsOneWidget);
    expect(find.text('Adoración'), findsOneWidget);
    expect(find.textContaining('18/10/2026'), findsOneWidget);
  });

  testWidgets('context preview fits a 390 px phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final controller = WorshipContextController(
      storage: _MemoryStorage(),
      pickFile: () async => null,
    );
    await tester.pumpWidget(
      LvmWorshipApp(
        contextController: controller,
        planController: _planController(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Repertorio'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
