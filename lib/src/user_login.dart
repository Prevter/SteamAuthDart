library steam_auth;

import 'dart:convert';

import 'api_endpoints.dart';
import 'time_aligner.dart';

import 'steam_web.dart';

class UserLogin {
  late String username;
  late String password;
  late int steamId;

  late bool requiresCaptcha;
  String captchaGid = "";
  String captchaText = "";

  late bool requiresEmail;
  String emailDomain = "";
  String emailCode = "";

  late bool requires2FA;
  String twoFactorCode = "";

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
    print(rsaResponse);
    if (!rsaResponse['success']) {
      return LoginResult.badRSA;
    }

    await Future.delayed(const Duration(milliseconds: 350));

    var passwordBytes = ascii.encode(password);
    // TODO: Finish login

    return LoginResult.loginOkay;
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
