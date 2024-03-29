import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:rivia/utilities/http_requests.dart';

import 'change_notifiers.dart';

const String _microsoftLoginBaseUrl =
    'https://login.microsoftonline.com/common';
const String _microsoftGraphBaseUrl = 'https://graph.microsoft.com/v1.0';
const String _clientId = '491d67e2-00cf-46ce-87cc-7e315c09b59f';
const String _redirectUri = 'https%3A%2F%2Fapp.rivia.me/';
const String _pxceChallenge = 'OE_eNjbm4B4BlNKXbY8mQQrz6EblczecsaCeLwdS2Mw';
const String _pxceVerifier = '114514';

/// Microsoft Teams & Azure related APIs.

/// Log the user in via their Microsoft account.
void microsoftLogin() {
  window.open(
    '$_microsoftLoginBaseUrl/oauth2/v2.0/authorize?client_id=$_clientId&response_type=code&redirect_uri=$_redirectUri&response_mode=query&scope=User.Read',
    '_self',
  );
}

/// Log the admin in via their Microsoft account.
void microsoftLoginAdmin() {
  window.open(
    '$_microsoftLoginBaseUrl/adminconsent?client_id=$_clientId&redirect_uri=$_redirectUri&response_mode=query',
    '_self',
  );
}

/// Get the tokens based on the code and save them.
Future<bool> microsoftGetTokens(String code) async {
  final response = await http.post(
    Uri.parse('$_microsoftLoginBaseUrl/oauth2/v2.0/token'),
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body:
        "client_id=$_clientId&scope=ChannelMessage.Send&code=$code&redirect_uri=$_redirectUri&grant_type=authorization_code&code_verifier=$_pxceVerifier",
  );

  if (response.statusCode == 200) {
    authToken.token = json.decode(response.body)['access_token'];
    authToken.refreshToken = json.decode(response.body)['refresh_token'];
    setSharedPref();
    return true;
  }

  return false;
}

/// Attempt to fetch the user id and tenant id from Microsoft Graph. Set the
/// userId in [authToken] to null if failed (not logged in).
Future<bool> microsoftGetUserId(String? code) async {
  if (authToken.userId != null && authToken.tenantId != null) {
    return true;
  }

  if (code == null) {
    // No code; not logged in
    authToken.reset();
    return false;
  } else {
    await foo(code);
    return true;
    // final response = await http.get(
    //   Uri.parse('$_microsoftGraphBaseUrl/me'),
    //   headers: {'Authorization': 'Bearer ${authToken.token}'},
    // );

    // if (response.statusCode == 200) {
    //   // User id fetched from microsoft
    //   final body = json.decode(response.body);
    //   authToken.userId = body['id'];
    //   final domain = (body['mail'] as String).split('@')[1];
    //   authToken.tenantId = (body['mail'] as String).split('@')[1];
    //   authToken.tenantId = (json.decode((await http.get(
    //     Uri.parse(
    //       'https://login.microsoftonline.com/$domain/.well-known/openid-configuration',
    //     ),
    //   ))
    //           .body)['token_endpoint'] as String)
    //       .split('/')[3];
    //   setSharedPref();
    // } else if (authToken.refreshToken == null) {
    //   // Refresh token is null. Should not happen
    //   print("Refresh token is null. Should not happen!");
    //   await authToken.reset();
    // } else if (await microsoftRefresh() == true) {
    //   // Refresh successful
    //   await microsoftGetUserId();
    // } else {
    //   // Refresh token expired, need to login again
    //   await authToken.reset();
    // }
  }
}

Future<bool> microsoftRefresh() async {
  if (authToken.refreshToken == null) {
    return false;
  }

  final response = await http.post(
    Uri.parse('$_microsoftLoginBaseUrl/oauth2/v2.0/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body:
        'client_id=$_clientId&scope=User.Read&refresh_token=${authToken.refreshToken}&redirect_uri=$_redirectUri&grant_type=refresh_token&code_verifier=$_pxceVerifier',
  );

  if (response.statusCode == 200) {
    authToken.token = json.decode(response.body)['access_token'];
    authToken.refreshToken = json.decode(response.body)['refresh_token'];
    setSharedPref();
    return true;
  }

  return false;
}
