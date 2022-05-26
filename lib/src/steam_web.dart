library steam_auth;

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'api_endpoints.dart';

/// Collection of request utilities
class SteamWeb {
  /// Preset to make mobile login requests
  static Future<String> mobileLoginRequest({
    required String url,
    required String method,
    required Map<String, String> body,
    required CookieJar? cookies,
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
    required CookieJar? cookies,
    required Map<String, String> headers,
    String referer = ApiEndpoints.communityBase,
  }) async {
    String query = "";

    if (body.isNotEmpty) {
      query = body.entries
          .map((e) => "${e.key}=${Uri.encodeComponent(e.value)}")
          .join("&");
    }

    return await requestStr(
      url: url,
      method: method,
      headers: headers,
      body: query,
      cookies: cookies,
      referer: referer,
    );
  }

  /// Sends request with correct cookies and headers
  static Future<String> requestStr({
    required String url,
    required String method,
    required String body,
    required CookieJar? cookies,
    required Map<String, String> headers,
    String referer = ApiEndpoints.communityBase,
  }) async {
    Response response;
    var dio = Dio();

    headers.addAll({
      'Accept': 'text/javascript, text/html, application/xml, text/xml, */*',
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.131 Mobile Safari/537.36',
      'Referer': referer,
    });

    if (cookies != null) {
      dio.interceptors.add(CookieManager(cookies));
    }

    if (method == "POST") {
      headers['Content-Type'] =
          'application/x-www-form-urlencoded; charset=UTF-8';
    } else {
      url += "?$body";
    }

    try {
      if (method == "POST") {
        response = await dio.postUri(
          Uri.parse(url),
          data: body,
          options: Options(
            headers: headers,
          ),
        );
      } else {
        response = await dio.getUri(
          Uri.parse(url),
          options: Options(
            headers: headers,
          ),
        );
      }
      return response.data.toString();
    } catch (e) {
      return "";
    }
  }
}
