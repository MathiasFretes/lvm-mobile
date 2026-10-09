import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ServicePreviewStorage {
  Future<String?> read();
  Future<void> write(String source);
  Future<void> clear();
}

final class DeviceServicePreviewStorage implements ServicePreviewStorage {
  DeviceServicePreviewStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'lvm.service.preview.0.1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read() => _preferences.getString(_key);

  @override
  Future<void> write(String source) => _preferences.setString(_key, source);

  @override
  Future<void> clear() => _preferences.remove(_key);
}

typedef ServiceFilePicker = Future<String?> Function();

Future<String?> pickServiceJson() async {
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'Service 0.1 JSON', extensions: ['json']),
    ],
  );
  if (file == null) return null;
  if (await file.length() > 5 * 1024 * 1024) {
    throw const FormatException('El archivo supera 5 MB.');
  }
  return file.readAsString();
}

final class ServicePreviewController extends ChangeNotifier {
  ServicePreviewController({required this.storage, required this.pickFile});

  final ServicePreviewStorage storage;
  final ServiceFilePicker pickFile;

  ServiceDocument? service;
  String? error;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final source = await storage.read();
      service = source == null ? null : ServiceDocument.parseJson(source);
    } catch (_) {
      service = null;
      error = 'No se pudo abrir el culto local guardado.';
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
    final ServiceDocument parsed;
    try {
      parsed = ServiceDocument.parseJson(source);
    } on FormatException {
      error = 'El archivo no cumple el contrato Service 0.1.';
      notifyListeners();
      return;
    }
    try {
      await storage.write(source);
      service = parsed;
      error = null;
    } catch (_) {
      error = 'No se pudo guardar el culto en este dispositivo.';
    }
    notifyListeners();
  }

  Future<void> clear() async {
    try {
      await storage.clear();
      service = null;
      error = null;
    } catch (_) {
      error = 'No se pudo quitar el culto local.';
    }
    notifyListeners();
  }
}
