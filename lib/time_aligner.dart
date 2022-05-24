library steam_auth;

import 'package:requests/requests.dart';

import 'api_endpoints.dart';
import 'util.dart';

class TimeAligner {
  static bool aligned = false;
  static int timeDifference = 0;

  static Future<int> getSteamTimeAsync() async {
    if (!aligned) {
      await alignTimeAsync();
    }
    return Util.getSystemUnixTime() + timeDifference;
  }

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

  static int getSteamTime() {
    return Util.getSystemUnixTime() + timeDifference;
  }
}
