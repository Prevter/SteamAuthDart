library steam_auth;

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
