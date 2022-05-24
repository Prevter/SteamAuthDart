import 'dart:typed_data';

class Util {
  static int getSystemUnixTime() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  static Uint8List hexStringToBytes(String hex) {
    int hexLen = hex.length;
    var ret = List.filled(hexLen ~/ 2, 0);
    for (int i = 0; i < hexLen; i += 2) {
      ret[i ~/ 2] = int.parse(hex.substring(i, i + 2), radix: 16);
    }
    return Uint8List.fromList(ret);
  }
}
