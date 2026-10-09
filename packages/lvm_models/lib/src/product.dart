class LvmProduct {
  const LvmProduct({
    required this.id,
    required this.name,
    required this.role,
    required this.applicationId,
  });

  final String id;
  final String name;
  final String role;

  /// Android applicationId. Distinct from the existing React Native app
  /// `com.lavozmisionera.app`.
  final String applicationId;

  static const congregacion = LvmProduct(
    id: 'lvm_public',
    name: 'La Voz Misionera',
    role: 'Congregantes y visitantes',
    applicationId: 'app.lavozmisionera.congregacion',
  );

  static const service = LvmProduct(
    id: 'lvm_service',
    name: 'LVM Service',
    role: 'Administración y planificación',
    applicationId: 'app.lavozmisionera.service',
  );

  static const worship = LvmProduct(
    id: 'lvm_worship',
    name: 'LVM Worship',
    role: 'Canciones, repertorios y herramientas musicales',
    applicationId: 'app.lavozmisionera.worship',
  );

  static const presenterRemote = LvmProduct(
    id: 'lvm_presenter_remote',
    name: 'LVM Presenter Remote',
    role: 'Control remoto de LVM Presenter en Windows',
    applicationId: 'app.lavozmisionera.presenterremote',
  );

  static const all = [congregacion, service, worship, presenterRemote];
}
