library steam_auth;

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'confirmation.dart';
import 'session_data.dart';
import 'api_endpoints.dart';
import 'steam_web.dart';
import 'time_aligner.dart';

class SteamGuardAccount {
  String sharedSecret;
  String? serialNumber;
  String revocationCode;
  String? uri;
  int? serverTime;
  String? accountName;
  String? tokenGid;
  String identitySecret;
  String? secret1;
  int? status;
  String deviceId;

  /// Set to true if the authenticator has actually been applied to the account.
  bool fullyEnrolled = false;
  SessionData? session;

  SteamGuardAccount({
    required this.sharedSecret,
    required this.identitySecret,
    required this.deviceId,
    required this.revocationCode,
    this.serialNumber = "",
    this.uri = "",
    this.serverTime = 0,
    this.accountName = "",
    this.tokenGid = "",
    this.secret1 = "",
    this.status = 1,
    this.fullyEnrolled = false,
  });

  static const List<String> steamChars = [
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "B",
    "C",
    "D",
    "F",
    "G",
    "H",
    "J",
    "K",
    "M",
    "N",
    "P",
    "Q",
    "R",
    "T",
    "V",
    "W",
    "X",
    "Y"
  ];

  /// Tries to remove Steam Guard from account.
  ///
  /// Requires an active [SessionData] present
  Future<bool> deactivateAuthenticator({int scheme = 2}) async {
    if (session == null) {
      throw Exception("Session is null");
    }

    var postData = {
      "steamid": session!.steamId.toString(),
      "steamguard_scheme": scheme.toString(),
      "revocation_code": revocationCode,
      "access_token": session!.oAuthToken
    };

    try {
      var response = await SteamWeb.mobileLoginRequest(
        url:
            "${ApiEndpoints.steamApiBase}/ITwoFactorService/RemoveAuthenticator/v0001",
        method: "POST",
        body: postData,
        headers: {},
        cookies: null,
      );
      var removeResponse = json.decode(response);
      if (response.isNotEmpty && removeResponse["response"]["success"]) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Generates a Steam Guard code for this account.
  String generateSteamGuardCode() {
    return generateSteamGuardCodeForTime(TimeAligner.getSteamTime());
  }

  /// Generates a Steam Guard code for a given time.
  String generateSteamGuardCodeForTime(int time) {
    if (sharedSecret.isEmpty) {
      return "";
    }

    Uint8List sharedSecretArray = base64Decode(sharedSecret);
    Uint8List timeArray = Uint8List(8);
    time ~/= 30;

    for (int i = 8; i > 0; i--) {
      timeArray[i - 1] = time & 0xFF;
      time = time >> 8;
    }

    var hmac = Hmac(sha1, sharedSecretArray).convert(timeArray).bytes;
    var codeArray = List.filled(5, "");
    try {
      int b = (hmac[19] & 0xF) % 0xFF;
      int codePoint = (hmac[b] & 0x7F) << 24 |
          (hmac[b + 1] & 0xFF) << 16 |
          (hmac[b + 2] & 0xFF) << 8 |
          (hmac[b + 3] & 0xFF);

      for (int i = 0; i < 5; i++) {
        codeArray[i] = steamChars[codePoint % steamChars.length];
        codePoint = codePoint ~/ steamChars.length;
      }
    } catch (e) {
      return "";
    }
    return codeArray.join("");
  }

  /// Returns a list of pending confirmations.
  Future<List<Confirmation>> fetchConfirmations() async {
    if (session == null) {
      throw Exception("Session is null");
    }

    String url = generateConfirmationURL();
    CookieJar cookies = CookieJar();
    session!.addCookies(cookies);

    String response = await SteamWeb.request(
      url: url,
      method: "GET",
      cookies: cookies,
      headers: {},
      body: {},
    );

    return fetchConfirmationInternal(response);
  }

  List<Confirmation> fetchConfirmationInternal(String response) {
    RegExp confirmationRegex = RegExp(
        "<div class=\"mobileconf_list_entry\" id=\"conf[0-9]+\" data-confid=\"(\\d+)\" data-key=\"(\\d+)\" data-type=\"(\\d+)\" data-creator=\"(\\d+)\"");
    if (response.isEmpty || !confirmationRegex.hasMatch(response)) {
      return [];
    }

    List<Confirmation> confirmations = [];
    for (Match match in confirmationRegex.allMatches(response)) {
      confirmations.add(Confirmation(
        id: match.group(1)!,
        key: match.group(2)!,
        intType: int.parse(match.group(3)!),
        creator: match.group(4)!,
      ));
    }

    return confirmations;
  }

  String generateConfirmationURL({String tag = "conf"}) {
    String endpoint = "${ApiEndpoints.communityBase}/mobileconf/conf?";
    String queryString = generateConfirmationQueryParams(tag);
    return "$endpoint$queryString";
  }

  String generateConfirmationQueryParams(String tag) {
    if (deviceId.isEmpty) {
      throw Exception("Device ID is not present");
    }

    var queryParams = generateConfirmationQueryParamsAsNVC(tag);
    return "p=${queryParams["p"]}&a=${queryParams["a"]}&k=${queryParams["k"]}&t=${queryParams["t"]}&m=android&tag=$tag";
  }

  Map<String, String> generateConfirmationQueryParamsAsNVC(tag) {
    if (session == null) {
      throw Exception("Session is null");
    }
    if (deviceId.isEmpty) {
      throw Exception("Device ID is not present");
    }

    int time = TimeAligner.getSteamTime();
    return {
      'p': deviceId,
      'a': session!.steamId.toString(),
      'k': generateConfirmationHashForTime(time, tag),
      't': time.toString(),
      'm': 'android',
      'tag': tag,
    };
  }

  String generateConfirmationHashForTime(int time, String tag) {
    var decode = base64Decode(identitySecret);
    int n2 = 8;
    if (tag.isNotEmpty) {
      if (tag.length > 32) {
        n2 = 8 + 32;
      } else {
        n2 = 8 + tag.length;
      }
    }
    Uint8List array = Uint8List.fromList(List.filled(n2, 0));
    int n3 = 8;
    while (true) {
      int n4 = n3 - 1;
      if (n3 <= 0) {
        break;
      }
      array[n4] = time & 0xFF;
      time = time >> 8;
      n3 = n4;
    }
    if (tag.isNotEmpty) {
      for (int i = 0; i < tag.length; i++) {
        array[8 + i] = tag.codeUnitAt(i);
      }
    }

    try {
      var hmac = Hmac(sha1, decode).convert(array).bytes;
      return base64UrlEncode(hmac);
    } catch (e) {
      return "";
    }
  }

  Future<bool> refreshSession() async {
    if (session == null) {
      throw Exception("Session is null");
    }

    String url = ApiEndpoints.mobileAuthGetWgToken;
    var postData = {
      'access_token': session!.oAuthToken,
    };

    String response = "";
    try {
      response = await SteamWeb.request(
        url: url,
        method: "POST",
        body: postData,
        headers: {},
        cookies: null,
      );
    } catch (e) {
      return false;
    }

    if (response.isEmpty) return false;

    try {
      var responseJson = json.decode(response);
      if (responseJson == null ||
          responseJson["response"] == null ||
          responseJson["response"]["token"] == null) {
        return false;
      }

      String token =
          "${session!.steamId}%7C%7C${responseJson["response"]["token"]}";
      String tokenSecure =
          "${session!.steamId}%7C%7C${responseJson["response"]["token_secure"]}";

      session!.steamLogin = token;
      session!.steamLoginSecure = tokenSecure;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<ConfirmationDetails?> getConfirmationDetails(
    Confirmation confirmation,
  ) async {
    if (session == null) {
      throw Exception("Session is null");
    }
    String url =
        "${ApiEndpoints.communityBase}/mobileconf/details/${confirmation.id}?";
    String queryString = generateConfirmationQueryParams("details");
    url += queryString;

    CookieJar cookies = CookieJar();
    session!.addCookies(cookies);
    String referer = generateConfirmationURL();

    String response = await SteamWeb.request(
      url: url,
      method: "GET",
      cookies: cookies,
      headers: {},
      body: {},
      referer: referer,
    );

    if (response.isEmpty) return null;

    var confResponse = jsonDecode(response);
    if (confResponse == null ||
        confResponse["success"] == null ||
        !confResponse["success"]) {
      return null;
    }

    return ConfirmationDetails(
      success: confResponse["success"],
      html: confResponse["html"],
    );
  }

  Future<bool> acceptMultipleConfirmations(List<Confirmation> confs) async {
    return await sendMultiConfirmationAjax(confs, "allow");
  }

  Future<bool> denyMultipleConfirmations(List<Confirmation> confs) async {
    return await sendMultiConfirmationAjax(confs, "cancel");
  }

  Future<bool> acceptConfirmation(Confirmation confirmation) async {
    return await sendConfirmationAjax(confirmation, "allow");
  }

  Future<bool> denyConfirmation(Confirmation confirmation) async {
    return await sendConfirmationAjax(confirmation, "cancel");
  }

  Future<bool> sendConfirmationAjax(
    Confirmation conf,
    String action,
  ) async {
    if (session == null) {
      throw Exception("Session is null");
    }
    String url = "${ApiEndpoints.communityBase}/mobileconf/multiajax";
    String queryString = "?op=$action&";
    queryString += generateConfirmationQueryParams(action);
    queryString += "&cid=${conf.id}&ck=${conf.key}";
    url += queryString;

    CookieJar cookies = CookieJar();
    session!.addCookies(cookies);
    String referer = generateConfirmationURL();

    String response = await SteamWeb.request(
      url: url,
      method: "GET",
      cookies: cookies,
      headers: {},
      body: {},
      referer: referer,
    );

    if (response.isEmpty) return false;

    var confResponse = jsonDecode(response);
    if (confResponse == null ||
        confResponse["success"] == null ||
        !confResponse["success"]) {
      return false;
    }

    return true;
  }

  Future<bool> sendMultiConfirmationAjax(
    List<Confirmation> confs,
    String action,
  ) async {
    if (session == null) {
      throw Exception("Session is null");
    }
    String url = "${ApiEndpoints.communityBase}/mobileconf/multiajaxop";
    String query = "op=$action&${generateConfirmationQueryParams(action)}";

    for (var conf in confs) {
      query += "&cid[]=${conf.id}&ck[]=${conf.key}";
    }

    CookieJar cookies = CookieJar();
    session!.addCookies(cookies);
    String referer = generateConfirmationURL();

    var response = await SteamWeb.requestStr(
      url: url,
      method: "POST",
      body: query,
      cookies: cookies,
      headers: {},
      referer: referer,
    );

    if (response.isEmpty) return false;

    var confResponse = jsonDecode(response);
    if (confResponse == null ||
        confResponse["success"] == null ||
        !confResponse["success"]) {
      return false;
    }

    return true;
  }

  static SteamGuardAccount fromJson(dynamic json) {
    var account = SteamGuardAccount(
      sharedSecret: json["shared_secret"],
      serialNumber: json["serial_number"] ?? "",
      revocationCode: json["revocation_code"],
      uri: json["uri"] ?? "",
      serverTime: json["server_time"] ?? 0,
      accountName: json["account_name"] ?? "",
      tokenGid: json["token_gid"] ?? "",
      identitySecret: json["identity_secret"],
      secret1: json["secret_1"] ?? "",
      status: json["status"] ?? 1,
      deviceId: json["device_id"],
      fullyEnrolled: json["fully_enrolled"] ?? false,
    );

    if (json["Session"] != null) {
      account.session = SessionData.fromJson(json["Session"]);
    }

    return account;
  }

  dynamic toJson() {
    return {
      "shared_secret": sharedSecret,
      "serial_number": serialNumber,
      "revocation_code": revocationCode,
      "uri": uri,
      "server_time": serverTime,
      "account_name": accountName,
      "token_gid": tokenGid,
      "identity_secret": identitySecret,
      "secret_1": secret1,
      "status": status,
      "device_id": deviceId,
      "fully_enrolled": fullyEnrolled,
      "Session": session?.toJson(),
    };
  }
}
