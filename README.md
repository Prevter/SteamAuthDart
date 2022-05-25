Unofficial port of a C# library to manage mobile Steam Guard and trades. 

## Getting started
Import library:
```dart
import 'package:steam_auth/steam_auth.dart';
```
Align time at the start of the program:
```dart
void main() async {
  await TimeAligner.alignTimeAsync();
  // Other code
}
```
Now you can use the library

## Examples

Generating Steam Guard code from existing keys:
```dart
SteamGuardAccount account = SteamGuardAccount(
  sharedSecret: '',
  serialNumber: '',
  revocationCode: '',
  uri: '',
  serverTime: '',
  accountName: '',
  tokenGid: '',
  identitySecret: '',
  secret1: '',
  status: '',
  deviceId: '',
  fullyEnrolled: false,
);

account.generateSteamGuardCode(); // One time code
```

Authenticating to fetch trades:
```dart
// Fill credentials
UserLogin login = UserLogin(
  username: "", 
  password: "",
);

LoginResult response = LoginResult.badCredentials;
// Call 'await login.doLogin()' after filling data
while ((response = await login.doLogin()) != LoginResult.loginOkay) {
  switch (response) {
    case LoginResult.needEmail:
      login.emailCode = ""; // Get code from user
      break;
    case LoginResult.needCaptcha:
      login.getCaptchaUrl(); // Show captcha to user
      login.captchaText = ""; // Get result
      break;
    case LoginResult.need2FA:
      login.twoFactorCode = account.generateSteamGuardCode(); // You can use created account
      // Or just ask user
      break;
    default:
      break;
  }
}

// 'login' now have existing session, which you can assign to SteamGuardAccount
account.session = login.session;

// And now just fetch trades
List<Confirmation> confirmations = await account.fetchConfirmations();
```

Accepting/Denying confirmations:
```dart
List<Confirmation> confirmations = await account.fetchConfirmations();

// Accepting only one:
await account.acceptConfirmation(confirmations[0]);

// Accepting multiple:
await account.acceptMultipleConfirmations(confirmations);

// Denying only one:
await account.denyConfirmation(confirmations[0]);

// Denying multiple:
await account.denyMultipleConfirmations(confirmations);
```

Creating new Steam Guard:
```dart
// You have to create SessionData first
AuthenticatorLinker linker = AuthenticatorLinker(session);

// Set phone if needed, or just don't add this line
linker.phoneNumber = "";

LinkResult result = await linker.addAuthenticator();
// There are 6 possible results:
// mustProvidePhoneNumber - You have to set 'phoneNumber' variable
// mustRemovePhoneNumber - You have to set 'phoneNumber' to null
// mustConfirmEmail - You have to confirm your Steam account
// generalFailure - Some unknown error
// authenticatorPresent - You already have authenticator
// awaitingFinalization - Proceed to next step

// When you got 'authenticatorPresent', you will recieve SMS code
FinalizeResult final = await linker.finilizeAddAuthenticator("SMS CODE");
// There are 4 results:
// badSMScode - Incorrect SMS code
// unableToGenerateCorrectCodes - Failed to generate valid Steam Guard codes
// generalFailure - Unknown error
// success

//After this you can save new account
var account = linker.linkedAccount;
```

## Credits
C# library: [SteamAuth](https://github.com/geel9/SteamAuth)