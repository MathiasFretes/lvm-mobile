import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class WorshipContextStorage {
  Future<String?> read();
  Future<void> write(String source);
  Future<void> clear();
}

final class DeviceWorshipContextStorage implements WorshipContextStorage {
  DeviceWorshipContextStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'lvm.worship.context.0.1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read() => _preferences.getString(_key);

  @override
  Future<void> write(String source) => _preferences.setString(_key, source);

  @override
  Future<void> clear() => _preferences.remove(_key);
}

typedef WorshipContextFilePicker = Future<String?> Function();

Future<String?> pickWorshipContextJson() async {
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'WorshipContext 0.1 JSON', extensions: ['json']),
    ],
  );
  if (file == null) return null;
  if (await file.length() > 1024 * 1024) {
    throw const FormatException('El archivo supera 1 MB.');
  }
  return file.readAsString();
}

final class WorshipContextController extends ChangeNotifier {
  WorshipContextController({required this.storage, required this.pickFile});

  final WorshipContextStorage storage;
  final WorshipContextFilePicker pickFile;

  WorshipContextDocument? context;
  String? error;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final source = await storage.read();
      context = source == null
          ? null
          : WorshipContextDocument.parseJson(source);
    } catch (_) {
      context = null;
      error = 'No se pudo abrir el contexto local guardado.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> importFile() async {
    try {
      final source = await pickFile();
      if (source != null) await importJson(source);
    } catch (_) {
      error = 'No se pudo leer el archivo seleccionado.';
      notifyListeners();
    }
  }

  Future<void> importJson(String source) async {
    final WorshipContextDocument parsed;
    try {
      parsed = WorshipContextDocument.parseJson(source);
    } on FormatException {
      error = 'El archivo no cumple el contrato WorshipContext 0.1.';
      notifyListeners();
      return;
    }
    try {
      await storage.write(source);
      context = parsed;
      error = null;
    } catch (_) {
      error = 'No se pudo guardar el contexto en este dispositivo.';
    }
    notifyListeners();
  }

  Future<void> clear() async {
    try {
      await storage.clear();
      context = null;
      error = null;
    } catch (_) {
      error = 'No se pudo quitar el contexto local.';
    }
    notifyListeners();
  }
}
