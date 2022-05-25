import 'package:steam_auth/steam_auth.dart';

void main() async {
  // Important to call this first
  await TimeAligner.alignTimeAsync();

  test('aligned', () {
    expect(TimeAligner.aligned, true);
  });
}
