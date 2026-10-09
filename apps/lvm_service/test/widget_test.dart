import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_service/main.dart';
import 'package:lvm_service/service_preview.dart';

final class _MemoryStorage implements ServicePreviewStorage {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String source) async => value = source;

  @override
  Future<void> clear() async => value = null;
}

const _service = {
  'schemaVersion': '0.1',
  'id': 'culto-1',
  'title': 'Culto General',
  'startsAt': '2026-10-18T19:00:00-03:00',
  'setlist': {'id': 'setlist-1', 'name': 'Domingo'},
  'items': [
    {
      'id': 'opening',
      'kind': 'ANNOUNCEMENT',
      'announcement': {'title': 'Bienvenida', 'body': 'Bienvenidos'},
    },
  ],
};

void main() {
  test('keeps the last valid file and restores it after reopen', () async {
    final storage = _MemoryStorage();
    final controller = ServicePreviewController(
      storage: storage,
      pickFile: () async => null,
    );
    await controller.importJson(jsonEncode(_service));
    expect(controller.service!.items.single.title, 'Bienvenida');
    await controller.importJson('{broken');
    expect(controller.service!.items.single.title, 'Bienvenida');
    expect(storage.value, jsonEncode(_service));
    final restored = ServicePreviewController(
      storage: storage,
      pickFile: () async => null,
    );
    await restored.load();
    expect(restored.service!.title, 'Culto General');
    await restored.clear();
    expect(storage.value, isNull);
  });

  testWidgets('imports a Service file and shows its ordered items', (
    tester,
  ) async {
    final controller = ServicePreviewController(
      storage: _MemoryStorage(),
      pickFile: () async => jsonEncode(_service),
    );
    await tester.pumpWidget(LvmServiceApp(previewController: controller));
    await tester.pumpAndSettle();
    expect(find.text('LVM Service'), findsWidgets);
    expect(find.byKey(const Key('lvm-emblem')), findsOneWidget);
    expect(lvmServiceBoundariesReady(), isFalse);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Cultos'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Todavía no hay un culto'), findsOneWidget);
    await tester.tap(find.text('Abrir Service 0.1'));
    await tester.pumpAndSettle();
    expect(find.text('Culto General'), findsOneWidget);
    expect(find.text('Bienvenida'), findsOneWidget);
  });

  testWidgets('service preview fits a 390 px phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final controller = ServicePreviewController(
      storage: _MemoryStorage(),
      pickFile: () async => null,
    );
    await tester.pumpWidget(LvmServiceApp(previewController: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(NavigationDestination, 'Cultos'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
