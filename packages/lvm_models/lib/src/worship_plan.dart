import 'dart:convert';

/// The music-only WorshipPlan 0.1 handoff owned by LVM Worship.
///
/// The schema mirrors the portable contract consumed by LVM Service. It does
/// not add Service metadata, people, permissions, or Presenter settings.
final class WorshipPlanDocument {
  const WorshipPlanDocument({
    required this.serviceId,
    required this.setlistId,
    required this.name,
    required this.songs,
  });

  final String serviceId;
  final String setlistId;
  final String name;
  final List<WorshipPlanSong> songs;

  static WorshipPlanDocument parseJson(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException {
      throw const FormatException('El archivo no contiene JSON válido.');
    }
    return parse(decoded);
  }

  static WorshipPlanDocument parse(Object? value) {
    final plan = _object(value, 'worshipPlan', {
      'schemaVersion',
      'serviceId',
      'setlistId',
      'name',
      'songs',
    });
    if (plan['schemaVersion'] != '0.1') {
      throw const FormatException(
        'worshipPlan.schemaVersion: se requiere 0.1.',
      );
    }
    final songsValue = plan['songs'];
    if (songsValue is! List || songsValue.isEmpty) {
      throw const FormatException(
        'worshipPlan.songs: se requiere al menos una canción.',
      );
    }
    final songs = <WorshipPlanSong>[];
    for (var index = 0; index < songsValue.length; index++) {
      songs.add(_parseSong(songsValue[index], 'worshipPlan.songs[$index]'));
    }
    return WorshipPlanDocument(
      serviceId: _text(plan['serviceId'], 'worshipPlan.serviceId'),
      setlistId: _text(plan['setlistId'], 'worshipPlan.setlistId'),
      name: _text(plan['name'], 'worshipPlan.name'),
      songs: List.unmodifiable(songs),
    );
  }

  Map<String, Object> toJson() => {
    'schemaVersion': '0.1',
    'serviceId': serviceId,
    'setlistId': setlistId,
    'name': name,
    'songs': songs.map((song) => song.toJson()).toList(growable: false),
  };

  String encodeJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}

final class WorshipPlanSong {
  const WorshipPlanSong({
    required this.songId,
    required this.title,
    required this.key,
    required this.arrangement,
    required this.sections,
  });

  final String songId;
  final String title;
  final String key;
  final List<int> arrangement;
  final List<WorshipPlanSection> sections;

  Map<String, Object> toJson() => {
    'songId': songId,
    'title': title,
    'key': key,
    'arrangement': arrangement,
    'sections': sections
        .map((section) => section.toJson())
        .toList(growable: false),
  };
}

final class WorshipPlanSection {
  const WorshipPlanSection({
    required this.kind,
    required this.label,
    required this.lines,
  });

  final String kind;
  final String label;
  final List<WorshipPlanLine> lines;

  Map<String, Object> toJson() => {
    'kind': kind,
    'label': label,
    'lines': lines.map((line) => line.toJson()).toList(growable: false),
  };
}

final class WorshipPlanLine {
  const WorshipPlanLine({required this.text, required this.chords});

  final String text;
  final List<WorshipPlanChord> chords;

  Map<String, Object> toJson() => {
    'text': text,
    'chords': chords.map((chord) => chord.toJson()).toList(growable: false),
  };
}

final class WorshipPlanChord {
  const WorshipPlanChord({required this.symbol, required this.index});

  final String symbol;
  final int index;

  Map<String, Object> toJson() => {'symbol': symbol, 'index': index};
}

WorshipPlanSong _parseSong(Object? value, String path) {
  final song = _object(value, path, {
    'songId',
    'title',
    'key',
    'arrangement',
    'sections',
  });
  final rawArrangement = song['arrangement'];
  if (rawArrangement is! List ||
      rawArrangement.isEmpty ||
      rawArrangement.any((value) => value is! int || value < 1)) {
    throw FormatException(
      '$path.arrangement: se requieren números de sección positivos.',
    );
  }
  final rawSections = song['sections'];
  if (rawSections is! List || rawSections.length != rawArrangement.length) {
    throw FormatException('$path.sections: debe coincidir con arrangement.');
  }
  final sections = <WorshipPlanSection>[];
  for (var index = 0; index < rawSections.length; index++) {
    sections.add(_parseSection(rawSections[index], '$path.sections[$index]'));
  }
  return WorshipPlanSong(
    songId: _text(song['songId'], '$path.songId'),
    title: _text(song['title'], '$path.title'),
    key: _string(song['key'], '$path.key'),
    arrangement: List.unmodifiable(rawArrangement.cast<int>()),
    sections: List.unmodifiable(sections),
  );
}

WorshipPlanSection _parseSection(Object? value, String path) {
  final section = _object(value, path, {'kind', 'label', 'lines'});
  final rawLines = section['lines'];
  if (rawLines is! List || rawLines.isEmpty) {
    throw FormatException('$path.lines: se requiere al menos una línea.');
  }
  final lines = <WorshipPlanLine>[];
  for (var index = 0; index < rawLines.length; index++) {
    lines.add(_parseLine(rawLines[index], '$path.lines[$index]'));
  }
  return WorshipPlanSection(
    kind: _text(section['kind'], '$path.kind'),
    label: _text(section['label'], '$path.label'),
    lines: List.unmodifiable(lines),
  );
}

WorshipPlanLine _parseLine(Object? value, String path) {
  final line = _object(value, path, {'text', 'chords'});
  final text = _text(line['text'], '$path.text');
  final rawChords = line['chords'];
  if (rawChords is! List) {
    throw FormatException('$path.chords: se requiere una lista.');
  }
  final chords = <WorshipPlanChord>[];
  for (var index = 0; index < rawChords.length; index++) {
    final chordPath = '$path.chords[$index]';
    final chord = _object(rawChords[index], chordPath, {'symbol', 'index'});
    final offset = chord['index'];
    if (offset is! int ||
        offset < 0 ||
        offset > text.length ||
        (offset > 0 &&
            offset < text.length &&
            _isHighSurrogate(text.codeUnitAt(offset - 1)) &&
            _isLowSurrogate(text.codeUnitAt(offset)))) {
      throw FormatException('$chordPath.index: offset UTF-16 inválido.');
    }
    chords.add(
      WorshipPlanChord(
        symbol: _text(chord['symbol'], '$chordPath.symbol'),
        index: offset,
      ),
    );
  }
  return WorshipPlanLine(text: text, chords: List.unmodifiable(chords));
}

Map<String, Object?> _object(Object? value, String path, Set<String> keys) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('$path: se requiere un objeto.');
  }
  for (final key in value.keys) {
    if (!keys.contains(key)) {
      throw FormatException('$path.$key: campo desconocido.');
    }
  }
  return value;
}

String _text(Object? value, String path) {
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$path: se requiere texto no vacío.');
  }
  return value;
}

String _string(Object? value, String path) {
  if (value is! String) throw FormatException('$path: se requiere texto.');
  return value;
}

bool _isHighSurrogate(int value) => value >= 0xd800 && value <= 0xdbff;
bool _isLowSurrogate(int value) => value >= 0xdc00 && value <= 0xdfff;
