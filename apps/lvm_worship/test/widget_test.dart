import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_worship/main.dart';
import 'package:lvm_worship/worship_context_preview.dart';

final class _MemoryStorage implements WorshipContextStorage {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String source) async => value = source;

  @override
  Future<void> clear() async => value = null;
}

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

  testWidgets('imports and shows a WorshipContext from Service', (
    tester,
  ) async {
    final controller = WorshipContextController(
      storage: _MemoryStorage(),
      pickFile: () async => jsonEncode(_context),
    );
    await tester.pumpWidget(LvmWorshipApp(contextController: controller));
    await tester.pumpAndSettle();
    expect(find.text('LVM Worship'), findsWidgets);
    expect(find.byKey(const Key('lvm-emblem')), findsOneWidget);
    expect(lvmWorshipBoundariesReady(), isFalse);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Repertorio'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Todavía no hay un culto'), findsOneWidget);
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
    await tester.pumpWidget(LvmWorshipApp(contextController: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Repertorio'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
