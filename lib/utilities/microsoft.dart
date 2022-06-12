import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:rivia/constants/languages.dart';

import 'change_notifiers.dart';

const String _microsoftLoginBaseUrl =
    'https://login.microsoftonline.com/common/oauth2/v2.0';
const String _clientId = '491d67e2-00cf-46ce-87cc-7e315c09b59f';
const String _redirectUri = 'https%3A%2F%2Fapp.rivia.me';
const String _pxceChallenge = 'OE_eNjbm4B4BlNKXbY8mQQrz6EblczecsaCeLwdS2Mw';
const String _pxceVerifier = '114514';

/// Microsoft Teams & Azure related APIs.

/// Log the user in via their Microsoft account, opening a new tab.
void microsoftLogin() {
  window.open(
    '$_microsoftLoginBaseUrl/authorize?client_id=$_clientId&response_type=code&redirect_uri=$_redirectUri&response_mode=query&scope=User.ReadWrite.All&code_challenge=$_pxceChallenge&code_challenge_method=S256',
    '_self',
  );
}

/// Get the tokens based on the code and save them.
Future<bool> microsoftGetTokens(String code) async {
  final response = await http.post(
    Uri.parse(
      '$_microsoftLoginBaseUrl/token',
    ),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body:
        "client_id=$_clientId&scope=offline_access%20User.ReadWrite.All&code=$code&redirect_uri=https%3A%2F%2Fapp.rivia.me&grant_type=authorization_code&code_verifier=$_pxceVerifier",
  );

  if (response.statusCode == 200) {
    authToken.token = json.decode(response.body)['access_token'];
    authToken.refreshToken = json.decode(response.body)['refresh_token'];
    setSharedPref(language);
    return true;
  }

  return false;
}

/// Attempt to fetch data from Microsoft Graph. Returns null if failed (not
/// logged in).
Future<void> microsoftFetch() async {}

void microsoftRefresh() {}
