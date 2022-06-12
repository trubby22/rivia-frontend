import 'dart:html' as html;

final String _microsoftLoginBaseUrl =
    'https://login.microsoftonline.com/common/oauth2/v2.0/';

final String _clientId = '491d67e2-00cf-46ce-87cc-7e315c09b59f';

final String _redirectUri = 'https%3A%2F%2Fapp.rivia.me';

final String _pxceChallenge = 'OE_eNjbm4B4BlNKXbY8mQQrz6EblczecsaCeLwdS2Mw';

/// Microsoft Teams & Azure related APIs.

/// Log the user in via their Microsoft account, opening a new tab.
void microsoftLogin() {
  html.window.open(
    '$_microsoftLoginBaseUrl/authorize?client_id=$_clientId&response_type=code&redirect_uri=$_redirectUri&response_mode=query&scope=User.ReadWrite.All&code_challenge=$_pxceChallenge&code_challenge_method=S256',
    '_self',
  );
}
