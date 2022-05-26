library steam_auth;

import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';

/// Contains current session data
///
/// Primarely used internally, but you should save it to
/// not login everytime
class SessionData {
  late String sessionId;
  late String steamLogin;
  late String steamLoginSecure;
  late String webCookie;
  late String oAuthToken;
  late int steamId;

  SessionData(
      {required this.sessionId,
      required this.steamLogin,
      required this.steamLoginSecure,
      required this.webCookie,
      required this.oAuthToken,
      required this.steamId});

  /// Sets cookies from session data
  void addCookies(CookieJar cookies) {
    cookies.saveFromResponse(
      Uri.parse("steamcommunity.com"),
      [
        Cookie('mobileClientVersion', '0 (2.1.3)'),
        Cookie('mobileClient', 'android'),
        Cookie('steamid', steamId.toString()),
        Cookie('steamLogin', steamLogin),
        Cookie('steamLoginSecure', steamLoginSecure),
        Cookie('sessionid', sessionId),
        Cookie('dob', ''),
        Cookie('Steam_Language', 'english'),
      ],
    );
  }

  // Constructs session data from json object
  static SessionData fromJson(dynamic json) {
    return SessionData(
      sessionId: json['SessionID'],
      steamLogin: json['SteamLogin'],
      steamLoginSecure: json['SteamLoginSecure'],
      webCookie: json['WebCookie'],
      oAuthToken: json['OAuthToken'],
      steamId: json['SteamID'],
    );
  }

  /// Returns session data as json object
  dynamic toJson() {
    return {
      'SessionID': sessionId,
      'SteamLogin': steamLogin,
      'SteamLoginSecure': steamLoginSecure,
      'WebCookie': webCookie,
      'OAuthToken': oAuthToken,
      'SteamID': steamId,
    };
  }
}
