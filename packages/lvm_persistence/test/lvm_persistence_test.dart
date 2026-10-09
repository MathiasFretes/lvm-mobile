import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_persistence/lvm_persistence.dart';

void main() {
  test('unimplemented store refuses access', () async {
    const store = UnimplementedLvmStore();
    expect(store.isAvailable, isFalse);
    expect(() => store.read('theme'), throwsUnsupportedError);
    expect(() => store.write('theme', 'dark'), throwsUnsupportedError);
  });
}
