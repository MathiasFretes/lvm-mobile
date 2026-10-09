import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_models/lvm_models.dart';

const _song = {
  'id': 'song-a',
  'title': 'Señor fiel',
  'key': 'G',
  'sections': [
    {
      'kind': 'VERSE',
      'label': 'Verso 1',
      'lines': [
        {
          'text': 'Fe 😀 aquí',
          'chords': [
            {'symbol': 'G', 'index': 6},
          ],
        },
      ],
    },
  ],
};

const _valid = {
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
    {'id': 'song-1', 'kind': 'SONG', 'song': _song},
    {
      'id': 'scripture-1',
      'kind': 'SCRIPTURE',
      'scripture': {
        'reference': 'Salmo 23:1',
        'version': 'RVR',
        'text': 'El Señor es mi pastor',
      },
    },
  ],
};

void main() {
  test('reads the exported LVM Service fixture', () {
    // Snapshot from LVM Service/fixtures/platform-service.json.
    final source = File(
      'packages/lvm_models/test/fixtures/platform-service.json',
    ).readAsStringSync();
    final service = ServiceDocument.parseJson(source);
    expect(service.id, 'platform-demo-2026-10-04');
    expect(service.items.length, 6);
    expect(service.items.first.title, 'Bienvenida');
    expect(service.items.last.kind, 'SERMON');
  });

  test('reads Service 0.1 and retains order and timezone', () {
    final service = ServiceDocument.parseJson(jsonEncode(_valid));
    expect(service.title, 'Culto General');
    expect(service.startsAtIso, '2026-10-18T19:00:00-03:00');
    expect(service.startsAt.toUtc(), DateTime.utc(2026, 10, 18, 22));
    expect(service.items.map((item) => item.title), [
      'Bienvenida',
      'Señor fiel',
      'Salmo 23:1',
    ]);
    expect(service.items[1].detail, '1 secciones · G');
  });

  test('rejects future versions, unknown fields and duplicate IDs', () {
    expect(
      () => ServiceDocument.parse({..._valid, 'schemaVersion': '0.2'}),
      throwsFormatException,
    );
    expect(
      () => ServiceDocument.parse({..._valid, 'extra': true}),
      throwsFormatException,
    );
    expect(
      () => ServiceDocument.parse({
        ..._valid,
        'items': [
          (_valid['items']! as List).first,
          (_valid['items']! as List).first,
        ],
      }),
      throwsFormatException,
    );
  });

  test('rejects mismatched payloads and split UTF-16 surrogate pair', () {
    expect(
      () => ServiceDocument.parse({
        ..._valid,
        'items': [
          {
            'id': 'bad',
            'kind': 'SONG',
            'song': _song,
            'sermon': {'title': 'x', 'body': 'y'},
          },
        ],
      }),
      throwsFormatException,
    );
    final section = (_song['sections']! as List).single as Map<String, Object?>;
    final line = (section['lines']! as List).single as Map<String, Object?>;
    final brokenSong = {
      ..._song,
      'sections': [
        {
          ...section,
          'lines': [
            {
              ...line,
              'chords': [
                {'symbol': 'G', 'index': 4},
              ],
            },
          ],
        },
      ],
    };
    expect(
      () => ServiceDocument.parse({
        ..._valid,
        'items': [
          {'id': 'bad', 'kind': 'SONG', 'song': brokenSong},
        ],
      }),
      throwsFormatException,
    );
  });

  test('allows a valid service without songs', () {
    final service = ServiceDocument.parse({
      ..._valid,
      'items': [(_valid['items']! as List).first],
    });
    expect(service.items.single.kind, 'ANNOUNCEMENT');
  });
}
