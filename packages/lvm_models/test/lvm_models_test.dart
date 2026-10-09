import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_models/lvm_models.dart';

void main() {
  test('android ids are unique and avoid the existing worship app', () {
    final ids = LvmProduct.all.map((product) => product.applicationId).toList();
    expect(ids.toSet(), hasLength(ids.length));
    expect(ids, [
      'app.lavozmisionera.congregacion',
      'app.lavozmisionera.service',
      'app.lavozmisionera.worship',
      'app.lavozmisionera.presenterremote',
    ]);
    expect(ids, isNot(contains('com.lavozmisionera.app')));
  });
}
