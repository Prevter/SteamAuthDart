library steam_auth;

import 'package:requests/requests.dart';

import 'api_endpoints.dart';
import 'util.dart';

/// Alignes time with Steam servers
class TimeAligner {
  static bool aligned = false;
  static int timeDifference = 0;

  /// Sets up alignment
  ///
  /// Should be called once in the beginning
  static Future<void> alignTimeAsync() async {
    int currentTime = Util.getSystemUnixTime();
    try {
      var response = await Requests.post(
        ApiEndpoints.twoFactorTimeQuery,
        body: {'steamid': '0'},
      );
      if (response.statusCode == 200) {
        var json = response.json();
        if (json['response'] != null) {
          int serverTime = int.parse(json['response']['server_time']);
          timeDifference = serverTime - currentTime;
          aligned = true;
        }
      }
    } catch (e) {
      return;
    }
  }

  /// Returns aligned timestamp
  static int getSteamTime() {
    return Util.getSystemUnixTime() + timeDifference;
  }
}
