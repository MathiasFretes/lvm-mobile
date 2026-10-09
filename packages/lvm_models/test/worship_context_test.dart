import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_models/lvm_models.dart';

const valid = {
  'schemaVersion': '0.1',
  'serviceId': 'culto-2026-10-18',
  'title': 'Culto General',
  'startsAt': '2026-10-18T19:00:00-03:00',
  'setlistId': 'setlist-culto-2026-10-18',
  'name': 'Adoración',
};

void main() {
  test('reads WorshipContext 0.1 and preserves its source identifiers', () {
    final context = WorshipContextDocument.parseJson(jsonEncode(valid));
    expect(context.serviceId, 'culto-2026-10-18');
    expect(context.setlistId, 'setlist-culto-2026-10-18');
    expect(context.startsAt.toUtc(), DateTime.utc(2026, 10, 18, 22));
    expect(context.startsAtIso, '2026-10-18T19:00:00-03:00');
  });

  test('rejects future versions, unknown fields and invalid dates', () {
    expect(
      () => WorshipContextDocument.parse({...valid, 'schemaVersion': '0.2'}),
      throwsFormatException,
    );
    expect(
      () => WorshipContextDocument.parse({...valid, 'items': []}),
      throwsFormatException,
    );
    expect(
      () => WorshipContextDocument.parse({...valid, 'startsAt': 'tomorrow'}),
      throwsFormatException,
    );
  });

  test('rejects missing or empty identity fields', () {
    expect(
      () => WorshipContextDocument.parse({...valid, 'name': ' '}),
      throwsFormatException,
    );
    final missing = {...valid}..remove('serviceId');
    expect(() => WorshipContextDocument.parse(missing), throwsFormatException);
  });
}
