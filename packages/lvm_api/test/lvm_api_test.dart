import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_api/lvm_api.dart';

void main() {
  test('api boundary is not configured', () {
    expect(const LvmApiBoundary().isConfigured, isFalse);
  });
}
