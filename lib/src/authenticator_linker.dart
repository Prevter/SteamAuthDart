library steam_auth;

import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'api_endpoints.dart';
import 'session_data.dart';
import 'steam_web.dart';
import 'steam_guard_account.dart';
import 'time_aligner.dart';

/// Handles the linking process for a new mobile authenticator.
class AuthenticatorLinker {
  /// Set to register a new phone number when linking.
  ///
  /// If a phone number is not set on the account, this must be set.
  /// If a phone number is set on the account, this must be null.
  String? phoneNumber;

  /// Randomly generated device ID.
  ///
  /// Should only be generated once per linker.
  late String deviceId;

  /// After the initial link step, if successful, this will be the SteamGuard data for the account.
  ///
  /// PLEASE save this somewhere after generating it; it's vital data.
  late SteamGuardAccount linkedAccount;

  /// True if the authenticator has been fully finalized
  bool finalized = false;

  SessionData session;
  CookieJar cookies = CookieJar();
  bool confirmationEmailSent = false;

  AuthenticatorLinker(this.session) {
    deviceId = generateDeviceId();
    session.addCookies(cookies);
  }

  /// Begins process of adding new Steam Guard
  Future<LinkResult> addAuthenticator() async {
    bool hasPhone = await hasPhoneAttached();
    if (hasPhone && phoneNumber != null) {
      return LinkResult.mustRemovePhoneNumber;
    }
    if (!hasPhone && phoneNumber == null) {
      return LinkResult.mustProvidePhoneNumber;
    }

    if (!hasPhone) {
      if (confirmationEmailSent) {
        if (!await checkEmailConfirmation()) {
          return LinkResult.generalFailure;
        }
      } else if (!await addPhoneNumber()) {
        return LinkResult.generalFailure;
      } else {
        confirmationEmailSent = true;
        return LinkResult.mustConfirmEmail;
      }
    }

    var postData = {
      'access_token': session.oAuthToken,
      'steamid': session.steamId,
      'authenticator_type': '1',
      'device_identifier': deviceId,
      'sms_phone_id': '1',
    };

    String response = await SteamWeb.mobileLoginRequest(
      url:
          '${ApiEndpoints.steamApiBase}/ITwoFactorService/AddAuthenticator/v0001',
      method: "POST",
      body: postData,
      cookies: null,
      headers: {},
    );

    if (response.isEmpty) return LinkResult.generalFailure;

    var addAuthenticatorResponse = jsonDecode(response);
    if (addAuthenticatorResponse['response'] == null) {
      return LinkResult.generalFailure;
    }

    if (addAuthenticatorResponse['response']['status'] == 29) {
      return LinkResult.authenticatorPresent;
    }

    if (addAuthenticatorResponse['response']['status'] != 1) {
      return LinkResult.generalFailure;
    }

    linkedAccount =
        SteamGuardAccount.fromJson(addAuthenticatorResponse['response']);
    linkedAccount.session = session;
    linkedAccount.deviceId = deviceId;

    return LinkResult.awaitingFinalization;
  }

  /// Finishes account initialization
  ///
  /// After success, you should save `linkedAccount`
  Future<FinalizeResult> finilizeAddAuthenticator(String smsCode) async {
    if (phoneNumber != null && !await checkSMSCode(smsCode)) {
      return FinalizeResult.badSMScode;
    }

    var postData = {
      'steamid': session.steamId,
      'access_token': session.oAuthToken,
      'activation_code': smsCode,
    };

    int tries = 0;
    while (tries <= 30) {
      postData['authenticator_code'] = linkedAccount.generateSteamGuardCode();
      postData['authenticator_time'] = TimeAligner.getSteamTime().toString();

      String response = await SteamWeb.mobileLoginRequest(
        url:
            '${ApiEndpoints.steamApiBase}/ITwoFactorService/FinalizeAddAuthenticator/v0001',
        method: "POST",
        body: postData,
        cookies: null,
        headers: {},
      );

      if (response.isEmpty) return FinalizeResult.generalFailure;

      var finalizeResponse = jsonDecode(response);
      if (finalizeResponse['response'] == null) {
        return FinalizeResult.generalFailure;
      }

      if (finalizeResponse['response']['status'] == 89) {
        return FinalizeResult.badSMScode;
      }
      if (finalizeResponse['response']['status'] == 88) {
        if (tries >= 30) {
          return FinalizeResult.unableToGenerateCorrectCodes;
        }
      }

      if (!finalizeResponse['response']['success']) {
        return FinalizeResult.generalFailure;
      }

      if (finalizeResponse['response']['want_more']) {
        tries++;
        continue;
      }

      linkedAccount.fullyEnrolled = true;
      return FinalizeResult.success;
    }

    return FinalizeResult.generalFailure;
  }

  /// Sends SMS code back to Steam to finish adding phone number.
  Future<bool> checkSMSCode(String smsCode) async {
    var postData = {
      'op': 'check_sms_code',
      'arg': smsCode,
      'checkfortos': '0',
      'skipvoid': '1',
      'sessionid': session.sessionId,
    };

    String response = await SteamWeb.request(
      url: "${ApiEndpoints.communityBase}/steamguard/phoneajax",
      method: "POST",
      body: postData,
      cookies: cookies,
      headers: {},
    );

    if (response.isEmpty) return false;

    var checkSMSCodeResponse = jsonDecode(response);

    if (checkSMSCodeResponse['success'] == false) {
      await Future.delayed(const Duration(milliseconds: 3500));
      return hasPhoneAttached();
    }

    return true;
  }

  Future<bool> checkEmailConfirmation() async {
    var postData = {
      'op': 'email_confirmation',
      'arg': '',
      'sessionid': session.sessionId,
    };

    String response = await SteamWeb.request(
      url: "${ApiEndpoints.communityBase}/steamguard/phoneajax",
      method: "POST",
      body: postData,
      cookies: cookies,
      headers: {},
    );

    if (response.isEmpty) return false;

    var responseJson = jsonDecode(response);
    if (responseJson['success'] == false) {
      return false;
    }

    return true;
  }

  /// Tries to attach phone number to account
  Future<bool> addPhoneNumber() async {
    var postData = {
      'op': 'add_phone_number',
      'arg': phoneNumber!,
      'sessionid': session.sessionId,
    };

    String response = await SteamWeb.request(
      url: "${ApiEndpoints.communityBase}/steamguard/phoneajax",
      method: "POST",
      body: postData,
      cookies: cookies,
      headers: {},
    );

    if (response.isEmpty) return false;

    var responseJson = jsonDecode(response);
    if (responseJson['success'] == false) {
      return false;
    }

    return true;
  }

  /// Checks whether account have attached phone
  Future<bool> hasPhoneAttached() async {
    var postData = {
      'op': 'has_phone',
      'arg': 'null',
      'sessionid': session.sessionId,
    };

    String response = await SteamWeb.request(
      url: "${ApiEndpoints.communityBase}/steamguard/phoneajax",
      method: "POST",
      body: postData,
      cookies: cookies,
      headers: {},
    );

    if (response.isEmpty) return false;

    var hasPhoneResponse = jsonDecode(response);
    return hasPhoneResponse['has_phone'];
  }

  /// Returns new device id
  static String generateDeviceId() {
    return "android:${const Uuid().v4()}";
  }
}

enum LinkResult {
  mustProvidePhoneNumber,
  mustRemovePhoneNumber,
  mustConfirmEmail,
  awaitingFinalization,
  generalFailure,
  authenticatorPresent,
}

enum FinalizeResult {
  badSMScode,
  unableToGenerateCorrectCodes,
  success,
  generalFailure,
}
