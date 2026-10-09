import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:lvm_models/lvm_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PublicContentStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> clear();
}

final class DevicePublicContentStorage implements PublicContentStorage {
  DevicePublicContentStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _key = 'lvm.publicContent.0.1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read() => _preferences.getString(_key);

  @override
  Future<void> write(String value) => _preferences.setString(_key, value);

  @override
  Future<void> clear() => _preferences.remove(_key);
}

typedef PublicContentFilePicker = Future<String?> Function();

Future<String?> pickPublicContentJson() async {
  final file = await openFile(
    acceptedTypeGroups: const [
      XTypeGroup(label: 'PublicContent JSON', extensions: ['json']),
    ],
  );
  if (file == null) return null;
  if (await file.length() > 5 * 1024 * 1024) {
    throw const FormatException('El archivo supera 5 MB.');
  }
  return file.readAsString();
}

final class PublicContentController extends ChangeNotifier {
  PublicContentController({
    required this.storage,
    required this.pickFile,
  });

  final PublicContentStorage storage;
  final PublicContentFilePicker pickFile;

  PublicContent? content;
  String? error;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final source = await storage.read();
      content = source == null ? null : PublicContent.parseJson(source);
    } catch (_) {
      content = null;
      error = 'No se pudo abrir el contenido local guardado.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> importFile() async {
    try {
      final source = await pickFile();
      if (source == null) return;
      await importJson(source);
    } catch (_) {
      error = 'No se pudo leer el archivo seleccionado.';
      notifyListeners();
    }
  }

  Future<void> importJson(String source) async {
    final PublicContent parsed;
    try {
      parsed = PublicContent.parseJson(source);
    } on FormatException {
      error = 'El archivo no cumple el contrato PublicContent 0.1.';
      notifyListeners();
      return;
    }
    try {
      await storage.write(source);
      content = parsed;
      error = null;
    } catch (_) {
      error = 'No se pudo guardar el contenido en este dispositivo.';
    }
    notifyListeners();
  }

  Future<void> clear() async {
    try {
      await storage.clear();
      content = null;
      error = null;
    } catch (_) {
      error = 'No se pudo quitar el contenido local.';
    }
    notifyListeners();
  }
}
