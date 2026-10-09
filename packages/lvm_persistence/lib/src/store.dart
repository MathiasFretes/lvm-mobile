/// Future local persistence boundary.
///
/// [UnimplementedLvmStore] refuses reads and writes. It is not a database.
abstract interface class LvmStore {
  bool get isAvailable;

  Future<String?> read(String key);

  Future<void> write(String key, String value);
}

final class UnimplementedLvmStore implements LvmStore {
  const UnimplementedLvmStore();

  @override
  bool get isAvailable => false;

  @override
  Future<String?> read(String key) {
    throw UnsupportedError('LVM persistence is not implemented.');
  }

  @override
  Future<void> write(String key, String value) {
    throw UnsupportedError('LVM persistence is not implemented.');
  }
}
