/// Marker for a future HTTP boundary.
///
/// M14A.1 does not define endpoints and does not return fabricated responses.
final class LvmApiBoundary {
  const LvmApiBoundary();

  bool get isConfigured => false;
}
