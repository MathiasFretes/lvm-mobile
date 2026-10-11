import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class WorshipPlanStorage {
  Future<String?> read(String serviceId);
  Future<void> write(String serviceId, String source);
  Future<void> clear(String serviceId);
}

final class DeviceWorshipPlanStorage implements WorshipPlanStorage {
  DeviceWorshipPlanStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _keyPrefix = 'lvm.worship.plan.0.1.';
  final SharedPreferencesAsync _preferences;

  String _key(String serviceId) => '$_keyPrefix$serviceId';

  @override
  Future<String?> read(String serviceId) =>
      _preferences.getString(_key(serviceId));

  @override
  Future<void> write(String serviceId, String source) =>
      _preferences.setString(_key(serviceId), source);

  @override
  Future<void> clear(String serviceId) => _preferences.remove(_key(serviceId));
}

typedef WorshipPlanSharer = Future<void> Function(
  String source,
  String fileName,
);

Future<void> shareWorshipPlan(String source, String fileName) async {
  await SharePlus.instance.share(
    ShareParams(
      title: 'WorshipPlan 0.1',
      text: 'Repertorio de LVM Worship para LVM Service.',
      files: [
        XFile.fromData(
          utf8.encode(source),
          mimeType: 'application/json',
          name: fileName,
        ),
      ],
      fileNameOverrides: [fileName],
    ),
  );
}

final class WorshipPlanController extends ChangeNotifier {
  WorshipPlanController({required this.storage, required this.sharePlan});

  final WorshipPlanStorage storage;
  final WorshipPlanSharer sharePlan;

  WorshipPlanDocument? plan;
  String? loadedServiceId;
  String? error;
  bool loading = false;

  Future<void> load(WorshipContextDocument context) async {
    if (loadedServiceId == context.serviceId) return;
    loading = true;
    error = null;
    loadedServiceId = context.serviceId;
    plan = null;
    notifyListeners();
    try {
      final source = await storage.read(context.serviceId);
      if (source != null) {
        final parsed = WorshipPlanDocument.parseJson(source);
        if (parsed.serviceId != context.serviceId ||
            parsed.setlistId != context.setlistId) {
          throw const FormatException('El repertorio pertenece a otro culto.');
        }
        plan = parsed;
      }
    } catch (_) {
      error = 'No se pudo abrir el repertorio local.';
      plan = null;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> reset() async {
    loadedServiceId = null;
    plan = null;
    error = null;
    loading = false;
    notifyListeners();
  }

  Future<void> addSong(
    WorshipContextDocument context,
    WorshipPlanSong song,
  ) async {
    final current = _planFor(context);
    await _save(
      context,
      WorshipPlanDocument(
        serviceId: context.serviceId,
        setlistId: context.setlistId,
        name: context.name,
        songs: [...current, song],
      ),
    );
  }

  Future<void> removeSong(WorshipContextDocument context, int index) async {
    final songs = [..._planFor(context)]..removeAt(index);
    if (songs.isEmpty) {
      try {
        await storage.clear(context.serviceId);
        plan = null;
        error = null;
      } catch (_) {
        error = 'No se pudo actualizar el repertorio local.';
      }
      notifyListeners();
      return;
    }
    await _save(
      context,
      WorshipPlanDocument(
        serviceId: context.serviceId,
        setlistId: context.setlistId,
        name: context.name,
        songs: songs,
      ),
    );
  }

  Future<void> moveSong(
    WorshipContextDocument context,
    int oldIndex,
    int newIndex,
  ) async {
    final songs = [..._planFor(context)];
    final song = songs.removeAt(oldIndex);
    songs.insert(newIndex, song);
    await _save(
      context,
      WorshipPlanDocument(
        serviceId: context.serviceId,
        setlistId: context.setlistId,
        name: context.name,
        songs: songs,
      ),
    );
  }

  Future<void> share(WorshipContextDocument context) async {
    final current = plan;
    if (current == null || current.songs.isEmpty) {
      error = 'Agregá al menos una canción antes de compartir el repertorio.';
      notifyListeners();
      return;
    }
    try {
      await sharePlan(
        current.encodeJson(),
        '${_safeFilePart(context.title)}-worship-plan.json',
      );
      error = null;
    } catch (_) {
      error = 'No se pudo abrir las opciones para compartir el repertorio.';
    }
    notifyListeners();
  }

  List<WorshipPlanSong> _planFor(WorshipContextDocument context) {
    if (plan?.serviceId == context.serviceId) return plan!.songs;
    return const [];
  }

  Future<void> _save(
    WorshipContextDocument context,
    WorshipPlanDocument next,
  ) async {
    try {
      final source = next.encodeJson();
      WorshipPlanDocument.parseJson(source);
      await storage.write(context.serviceId, source);
      plan = next;
      error = null;
    } catch (_) {
      error = 'No se pudo guardar el repertorio en este dispositivo.';
    }
    notifyListeners();
  }
}

String _safeFilePart(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '')
    .ifEmpty('repertorio');

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
