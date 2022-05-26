import 'package:steam_auth/steam_auth.dart';
import 'package:test/test.dart';

void main() async {
  test('aligned', () async {
    // Important to call this first
    await TimeAligner.alignTimeAsync();
    expect(TimeAligner.aligned, equals(true));
  });

  late SteamGuardAccount account;

  test('from json', () {
    // Some random data
    account = SteamGuardAccount.fromJson({
      'shared_secret': '1Kf32Bs241Oabcdefjhijkl+Mno=',
      'identity_secret': 'lEf5kV31qqHeLl0woRLdrZnb2uc=',
      'revocation_code': 'R17244',
      'device_id': 'android:5f453f29-c32a-4f24-a3ac-6dd6ee829984',
    });
    expect(account, isNotNull);
  });

  test('guard code', () {
    expect(account.generateSteamGuardCodeForTime(1653553147), equals("JJMKK"));
  });
}
