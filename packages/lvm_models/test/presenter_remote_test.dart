import 'package:flutter_test/flutter_test.dart';
import 'package:lvm_models/lvm_models.dart';

void main() {
  test('round trips the Presenter Remote 0.1 pairing link', () {
    const link = PresenterRemotePairingLink(
      host: '192.168.1.20',
      port: 4319,
      pairingId: 'pair-1',
      pairingSecret: 'secret-1',
    );

    final parsed = PresenterRemotePairingLink.parse(link.uri.toString());

    expect(
      parsed.socketUri.toString(),
      'ws://192.168.1.20:4319/lvm-remote/0.1',
    );
    expect(parsed.pairingId, 'pair-1');
  });

  test('rejects malformed, incomplete and out of range pairing links', () {
    for (final raw in [
      'https://example.com',
      'lvm-presenter://remote/0.1?host=192.168.1.20&port=0&pairingId=p&pairingSecret=s',
      'lvm-presenter://remote/0.1?host=192.168.1.20&port=4319&pairingId=p',
    ]) {
      expect(
        () => PresenterRemotePairingLink.parse(raw),
        throwsFormatException,
      );
    }
  });
}
