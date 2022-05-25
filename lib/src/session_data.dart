library steam_auth;

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
  late String steamId;

  SessionData(
      {required this.sessionId,
      required this.steamLogin,
      required this.steamLoginSecure,
      required this.webCookie,
      required this.oAuthToken,
      required this.steamId});

  /// Sets cookies map from session data
  void addCookies(Map<String, String> cookies) {
    cookies.addAll({
      'mobileClientVersion': '0 (2.1.3)',
      'mobileClient': 'android',
      'steamid': steamId,
      'steamLogin': steamLogin,
      'steamLoginSecure': steamLoginSecure,
      'Steam_Language': 'english',
      'dob': '',
      'sessionid': sessionId,
    });
  }
}
