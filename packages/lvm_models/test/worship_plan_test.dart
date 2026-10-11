import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_models/lvm_models.dart';

const valid = {
  'schemaVersion': '0.1',
  'serviceId': 'culto-2026-10-18',
  'setlistId': 'setlist-culto-2026-10-18',
  'name': 'Adoración',
  'songs': [
    {
      'songId': 'cantamos-con-fe',
      'title': 'Cantamos con fe',
      'key': 'G',
      'arrangement': [1, 2, 1],
      'sections': [
        {
          'kind': 'verse',
          'label': 'Verso',
          'lines': [
            {
              'text': 'Cantamos con fe',
              'chords': [
                {'symbol': 'G', 'index': 0},
              ],
            },
          ],
        },
        {
          'kind': 'chorus',
          'label': 'Coro',
          'lines': [
            {'text': 'Jesús es Señor', 'chords': []},
          ],
        },
        {
          'kind': 'verse',
          'label': 'Verso',
          'lines': [
            {
              'text': 'Cantamos con fe',
              'chords': [
                {'symbol': 'G', 'index': 0},
              ],
            },
          ],
        },
      ],
    },
  ],
};

void main() {
  test('reads and encodes the portable WorshipPlan 0.1 contract', () {
    final plan = WorshipPlanDocument.parseJson(jsonEncode(valid));

    expect(plan.serviceId, 'culto-2026-10-18');
    expect(plan.songs.single.arrangement, [1, 2, 1]);
    expect(WorshipPlanDocument.parseJson(plan.encodeJson()).toJson(), valid);
  });

  test('preserves repeated sections and accepts an offset at end of text', () {
    final source = {...valid};
    final song = Map<String, Object?>.from(
      (source['songs'] as List).single as Map,
    );
    final sections = List<Object?>.from(song['sections'] as List);
    final first = Map<String, Object?>.from(sections.first as Map);
    final lines = List<Object?>.from(first['lines'] as List);
    lines[0] = {
      'text': 'Fe',
      'chords': [
        {'symbol': 'G', 'index': 2},
      ],
    };
    first['lines'] = lines;
    sections[0] = first;
    song['sections'] = sections;
    source['songs'] = [song];

    expect(
      WorshipPlanDocument.parse(source).songs.single.sections,
      hasLength(3),
    );
  });

  test('rejects unknown fields and incompatible arrangement lengths', () {
    expect(
      () => WorshipPlanDocument.parse({...valid, 'future': true}),
      throwsFormatException,
    );
    final source = {...valid};
    final song = Map<String, Object?>.from(
      (source['songs'] as List).single as Map,
    );
    song['arrangement'] = [1, 2];
    source['songs'] = [song];
    expect(() => WorshipPlanDocument.parse(source), throwsFormatException);
  });

  test('rejects a chord offset that splits a UTF-16 surrogate pair', () {
    final source = {...valid};
    final song = Map<String, Object?>.from(
      (source['songs'] as List).single as Map,
    );
    final sections = List<Object?>.from(song['sections'] as List);
    final first = Map<String, Object?>.from(sections.first as Map);
    first['lines'] = [
      {
        'text': 'A😀B',
        'chords': [
          {'symbol': 'G', 'index': 2},
        ],
      },
    ];
    sections[0] = first;
    song['sections'] = sections;
    source['songs'] = [song];

    expect(() => WorshipPlanDocument.parse(source), throwsFormatException);
  });
}
