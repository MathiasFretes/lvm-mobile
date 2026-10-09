import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_models/lvm_models.dart';

void main() {
  final valid = <String, Object?>{
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
    'sermons': [
      {
        'id': 'predica-1',
        'title': 'La esperanza',
        'series': 'Vida',
        'speaker': 'Pastor',
        'date': '2026-10-17',
        'duration': '35 min',
        'summary': 'Una enseñanza',
      },
    ],
    'venues': [
      {
        'id': 'central',
        'name': 'Sede Central',
        'zone': 'Centro',
        'address': 'Dirección de ejemplo',
        'hours': 'Domingo 19:00',
        'isMain': true,
      },
    ],
  };

  test('accepts the Service PublicContent 0.1 shape', () {
    final content = PublicContent.parseJson(jsonEncode(valid));
    expect(content.events.single.title, 'Culto General');
    expect(content.sermons.single.speaker, 'Pastor');
    expect(content.venues.single.isMain, isTrue);
  });

  test('rejects unknown fields and future versions', () {
    expect(
      () => PublicContent.parse({...valid, 'unexpected': true}),
      throwsFormatException,
    );
    expect(
      () => PublicContent.parse({...valid, 'schemaVersion': '0.2'}),
      throwsFormatException,
    );
  });

  test('rejects duplicate ids and impossible dates', () {
    expect(
      () => PublicContent.parse({
        ...valid,
        'events': [
          (valid['events']! as List).first,
          (valid['events']! as List).first,
        ],
      }),
      throwsFormatException,
    );
    expect(
      () => PublicContent.parse({
        ...valid,
        'events': [
          {
            ...(valid['events']! as List).first as Map<String, Object?>,
            'date': '2026-02-30',
          },
        ],
      }),
      throwsFormatException,
    );
  });
}
