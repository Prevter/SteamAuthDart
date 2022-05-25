import 'dart:typed_data';

class Util {
  /// Returns timestamp in milliseconds
  static int getSystemUnixTime() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// Converts hex string to BigInt
  static BigInt hexStringToBigInt(String hex) {
    return BigInt.parse(hex, radix: 16);
  }

  /// Converts cookie map to a header string
  static String stringifyCookies(Map<String, String> cookies) =>
      cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
}
