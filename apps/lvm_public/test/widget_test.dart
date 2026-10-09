import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_public/main.dart';
import 'package:lvm_public/public_content.dart';

final class _MemoryStorage implements PublicContentStorage {
  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<void> write(String value) async => this.value = value;

  @override
  Future<void> clear() async => value = null;
}

const _valid = {
  'schemaVersion': '0.1',
  'generatedAt': '2026-10-07T15:00:00.000Z',
  'events': [
    {
      'id': 'culto-1',
      'title': 'Culto General',
      'date': '2026-10-17',
      'time': '19:00',
      'venue': 'Sede Central',
      'kind': 'culto',
      'description': 'Encuentro semanal',
    },
  ],
  'sermons': [],
  'venues': [],
};

void main() {
  test(
    'valid import persists; invalid replacement preserves the old document',
    () async {
      final storage = _MemoryStorage();
      final controller = PublicContentController(
        storage: storage,
        pickFile: () async => null,
      );
      await controller.importJson(jsonEncode(_valid));
      expect(controller.content!.events.single.title, 'Culto General');
      await controller.importJson('{broken');
      expect(controller.content!.events.single.title, 'Culto General');
      expect(storage.value, jsonEncode(_valid));

      final restored = PublicContentController(
        storage: storage,
        pickFile: () async => null,
      );
      await restored.load();
      expect(restored.content!.events.single.title, 'Culto General');
      await restored.clear();
      expect(storage.value, isNull);
    },
  );

  testWidgets('shows local content and empty states in the public app', (
    tester,
  ) async {
    final storage = _MemoryStorage();
    final controller = PublicContentController(
      storage: storage,
      pickFile: () async => jsonEncode(_valid),
    );
    await tester.pumpWidget(LvmPublicApp(contentController: controller));
    await tester.pumpAndSettle();
    expect(find.text('La Voz Misionera'), findsWidgets);
    expect(find.byKey(const Key('lvm-emblem')), findsOneWidget);
    expect(find.textContaining('Todavía no hay contenido'), findsOneWidget);
    expect(lvmPublicBoundariesReady(), isFalse);

    await tester.tap(find.text('Abrir PublicContent 0.1'));
    await tester.pumpAndSettle();
    expect(find.text('Eventos'), findsWidgets);
    await tester.tap(find.widgetWithText(NavigationDestination, 'Eventos'));
    await tester.pumpAndSettle();
    expect(find.text('Culto General'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Prédicas'));
    await tester.pumpAndSettle();
    expect(find.text('No hay prédicas en este archivo.'), findsOneWidget);

    await tester.tap(find.widgetWithText(NavigationDestination, 'Apariencia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('navigation fits a 390 px phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    final controller = PublicContentController(
      storage: _MemoryStorage(),
      pickFile: () async => null,
    );
    await tester.pumpWidget(LvmPublicApp(contentController: controller));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
  });
}
