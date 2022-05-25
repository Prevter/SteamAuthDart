library steam_auth;

import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:steam_auth/src/session_data.dart';
import 'dart:convert';

import 'api_endpoints.dart';
import 'time_aligner.dart';

import 'steam_web.dart';
import 'util.dart';

class UserLogin {
  String username;
  String password;
  int steamId = 0;

  bool requiresCaptcha = false;
  String captchaGid = "";
  String captchaText = "";

  bool requiresEmail = false;
  String emailDomain = "";
  String emailCode = "";

  bool requires2FA = false;
  String twoFactorCode = "";

  SessionData? session;
  bool loggedIn = false;

  Map<String, String> cookies = {};

  UserLogin({required this.username, required this.password});

  Future<LoginResult> doLogin() async {
    String response = "";

    if (cookies.isEmpty) {
      cookies.addAll({
        'mobileClientVersion': '0 (2.1.3)',
        'mobileClient': 'android',
        'Steam_Language': 'english',
      });

      await SteamWeb.mobileLoginRequest(
        url:
            "https://steamcommunity.com/login?oauth_client_id=DE45CD61&oauth_scope=read_profile%20write_profile%20read_client%20write_client",
        method: "GET",
        body: {},
        cookies: cookies,
        headers: {
          'X-Requested-With': 'com.valvesoftware.android.steam.community',
        },
      );
    }

    var postData = {
      'donotcache': (TimeAligner.getSteamTime() * 1000).toString(),
      'username': username,
    };

    response = await SteamWeb.mobileLoginRequest(
      url: "${ApiEndpoints.communityBase}/login/getrsakey",
      method: "POST",
      body: postData,
      cookies: cookies,
      headers: {},
    );

    if (response.isEmpty ||
        response.contains(
          "<BODY>\nAn error occurred while processing your request.",
        )) {
      return LoginResult.generalFailure;
    }

    var rsaResponse = jsonDecode(response);
    if (!rsaResponse['success']) {
      return LoginResult.badRSA;
    }

    await Future.delayed(const Duration(milliseconds: 350));

    var passwordBytes = ascii.encode(password);
    var pubKey = RSAPublicKey(
      Util.hexStringToBigInt(rsaResponse["publickey_mod"]),
      Util.hexStringToBigInt(rsaResponse["publickey_exp"]),
    );
    var cipher = PKCS1Encoding(RSAEngine());
    cipher.init(true, PublicKeyParameter<RSAPublicKey>(pubKey));
    Uint8List output = cipher.process(passwordBytes);
    var encryptedPassword = base64Encode(output);

    postData.clear();
    postData.addAll({
      'donotcache': (TimeAligner.getSteamTime() * 1000).toString(),
      'username': username,
      'password': encryptedPassword,
      'twofactorcode': twoFactorCode.isNotEmpty ? twoFactorCode : "",
      'emailauth': requiresEmail ? emailCode : "",
      'loginfriendlyname': "",
      'captchagid': requiresCaptcha ? captchaGid : "",
      'captcha_text': requiresCaptcha ? captchaText : "",
      'emailsteamid': (requiresEmail || requires2FA) ? steamId.toString() : "",
      'rsatimestamp': rsaResponse["timestamp"],
      'remember_login': "true",
      'oauth_client_id': "DE45CD61",
      'oauth_scope':
          "read_profile%20write_profile%20read_client%20write_client",
    });

    response = await SteamWeb.mobileLoginRequest(
      url: "${ApiEndpoints.communityBase}/login/dologin",
      method: "POST",
      body: postData,
      cookies: cookies,
      headers: {},
    );

    if (response.isEmpty) {
      return LoginResult.generalFailure;
    }

    var loginResponse = jsonDecode(response);

    if (loginResponse['message'] != null) {
      String message = loginResponse['message'];
      if (message.contains("There have been too many login failures")) {
        return LoginResult.tooManyFailedLogins;
      } else if (message.contains("Incorrect login")) {
        return LoginResult.badCredentials;
      }
    }

    if (loginResponse['captcha_needed'] != null &&
        loginResponse['captcha_needed']) {
      requiresCaptcha = true;
      captchaGid = loginResponse['captcha_gid'];
      return LoginResult.needCaptcha;
    }

    if (loginResponse['emailauth_needed'] != null &&
        loginResponse['emailauth_needed']) {
      requiresEmail = true;
      steamId = loginResponse['emailsteamid'];
      return LoginResult.needEmail;
    }

    if (loginResponse['requires_twofactor'] != null &&
        loginResponse['requires_twofactor'] &&
        !loginResponse['success']) {
      requires2FA = true;
      return LoginResult.need2FA;
    }

    if (loginResponse['oauth'] == null) {
      return LoginResult.generalFailure;
    } else {
      var oauth = jsonDecode(loginResponse['oauth']);
      if (oauth['oauth_token'] == null) {
        return LoginResult.generalFailure;
      }
    }

    if (loginResponse['login_complete'] == null ||
        !loginResponse['login_complete']) {
      return LoginResult.badCredentials;
    } else {
      var oAuthData = jsonDecode(loginResponse['oauth']);
      session = SessionData(
        sessionId: cookies["sessionid"]!,
        steamLogin: "${oAuthData['steamid']}%7C%7C${oAuthData['wgtoken']}",
        steamLoginSecure:
            "${oAuthData['steamid']}%7C%7C${oAuthData['wgtoken_secure']}",
        webCookie: oAuthData['webcookie'],
        oAuthToken: oAuthData['oauth_token'],
        steamId: oAuthData['steamid'],
      );
      loggedIn = true;
      return LoginResult.loginOkay;
    }
  }

  String getCaptchaUrl() {
    return "${ApiEndpoints.communityBase}/public/captcha.php?gid=$captchaGid";
  }
}

enum LoginResult {
  loginOkay,
  generalFailure,
  badRSA,
  badCredentials,
  needCaptcha,
  need2FA,
  needEmail,
  tooManyFailedLogins,
}