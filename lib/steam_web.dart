library steam_auth;

import 'package:requests/requests.dart';
import 'package:requests/src/cookie.dart';
import 'package:steam_auth/api_endpoints.dart';

class SteamWeb {
  static Future<String> mobileLoginRequest({
    required String url,
    required String method,
    required Map<String, String> body,
    required Map<String, String> cookies,
    required Map<String, String> headers,
  }) async {
    return await request(
      url: url,
      method: method,
      headers: headers,
      body: body,
      cookies: cookies,
      referer:
          "${ApiEndpoints.communityBase}/mobilelogin?oauth_client_id=DE45CD61&oauth_scope=read_profile%20write_profile%20read_client%20write_client",
    );
  }

  static Future<String> request({
    required String url,
    required String method,
    required Map<String, String> body,
    required Map<String, String> cookies,
    required Map<String, String> headers,
    String referer = ApiEndpoints.communityBase,
  }) async {
    headers.addAll({
      'Accept': 'text/javascript, text/html, application/xml, text/xml, */*',
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Mobile Safari/537.36',
      'Referer': referer,
    });
    await Requests.clearStoredCookies(Requests.getHostname(url));
    if (cookies.isNotEmpty) {
      CookieJar cookieJar = CookieJar();
      for (var cookie in cookies.entries) {
        cookieJar[cookie.key] = Cookie(cookie.key, cookie.value);
      }
      Requests.setStoredCookies(Requests.getHostname(url), cookieJar);
    }

    if (method == "POST") {
      headers['Content-Type'] =
          'application/x-www-form-urlencoded; charset=UTF-8';
    }

    try {
      String resultString = "";

      if (method == "POST") {
        var response = await Requests.post(url, body: body, headers: headers);
        resultString = response.body;
      } else {
        var response = await Requests.get(url, headers: headers);
        resultString = response.body;
      }
      var cookieJar =
          await Requests.getStoredCookies(Requests.getHostname(url));

      for (var cookie in cookieJar.values) {
        cookies[cookie.name] = cookie.value;
      }

      return resultString;
    } catch (e) {
      print(e);
      return "";
    }
  }
}
