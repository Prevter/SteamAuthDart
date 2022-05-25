library steam_auth;

/// API links collection
class ApiEndpoints {
  static const String steamApiBase = "https://api.steampowered.com";
  static const String communityBase = "https://steamcommunity.com";
  static const String mobileAuthBase =
      "https://api.steampowered.com/IMobileAuthService/%s/v0001";
  static const String twoFactorBase =
      "https://api.steampowered.com/ITwoFactorService/%s/v0001";

  static String mobileAuthGetWgToken =
      mobileAuthBase.replaceAll(RegExp('%s'), 'GetWGToken');
  static String twoFactorTimeQuery =
      twoFactorBase.replaceAll(RegExp('%s'), 'QueryTime');
}
