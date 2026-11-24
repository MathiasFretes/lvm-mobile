import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_design/lvm_design.dart';

void main() {
  testWidgets('compact identity preserves names with large system text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 112,
              title: const LvmBrandIdentity(product: 'Presenter Remote · Control'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('La Voz Misionera'), findsOneWidget);
    expect(find.text('Presenter Remote · Control'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
