import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_ui/lvm_ui.dart';

void main() {
  testWidgets('foundation identifies an unreleased product', (tester) async {
    await tester.pumpWidget(
      const LvmFoundationApp(
        product: 'LVM Service',
        audience: 'Líderes',
        plannedFeatures: ['Servicios'],
      ),
    );
    expect(find.text('LVM Service'), findsWidgets);
    expect(find.text('Base Android en desarrollo'), findsOneWidget);
    expect(find.text('Servicios'), findsOneWidget);
  });
}
