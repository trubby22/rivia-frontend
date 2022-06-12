import 'dart:convert';
import 'dart:math';

import 'dart:js' as js;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/login_credentials.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/sized_button.dart';
import 'package:rivia/utilities/toast.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  bool _signup = false;

  @override
  void initState() {
    super.initState();
    getLang(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final height = (_signup ? 1.15 : 1.0) *
        max(450.0, MediaQuery.of(context).size.height * 0.55);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(244, 242, 234, 1),
        body: Stack(
          children: [
            Positioned(
              right: 64.0,
              top: 24.0,
              child: SizedButton(
                backgroundColour: const Color.fromRGBO(239, 198, 135, 1),
                primaryColour: Colors.black,
                onPressedColour: const Color.fromRGBO(239, 198, 135, 1),
                height: 48.0,
                width: 100.0,
                onPressed: (_) async {
                  if (language == Lang.en) {
                    await setLang(Lang.ru);
                  } else {
                    await setLang(Lang.en);
                  }
                  setState(() {});
                },
                child: Text(
                  LangText.langCode.local,
                  style: UITexts.mediumButtonText,
                ),
              ),
            ),
            Center(
              child: Container(
                width: max(350, MediaQuery.of(context).size.width * 0.25),
                height: height,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                  color: Colors.blue.shade100,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 32.0),
                    Text(LangText.rivia.local, style: UITexts.iconHeader),
                    SizedBox(
                      height: (_signup ? 0.6 : 0.5) * height,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_signup) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(190, 150, 100, 1),
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  filled: true,
                                  labelText: LangText.firstName.local,
                                ),
                                controller: _firstNameController,
                              ),
                            ),
                            const SizedBox(height: 24.0),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: TextField(
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color.fromRGBO(190, 150, 100, 1),
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                  filled: true,
                                  labelText: LangText.surname.local,
                                ),
                                controller: _surnameController,
                              ),
                            ),
                            const SizedBox(height: 24.0),
                          ],
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: TextField(
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(190, 150, 100, 1),
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                filled: true,
                                labelText: LangText.email.local,
                              ),
                              controller: _loginController,
                            ),
                          ),
                          const SizedBox(height: 24.0),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: TextField(
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(190, 150, 100, 1),
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                ),
                                filled: true,
                                labelText: LangText.password.local,
                              ),
                              obscureText: true,
                              controller: _passwordController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Consumer<AuthToken>(
                      builder: (context, user, child) {
                        return SizedButton(
                          backgroundColour:
                              const Color.fromRGBO(239, 198, 135, 1),
                          primaryColour: Colors.black,
                          onPressedColour:
                              const Color.fromRGBO(239, 198, 135, 1),
                          height: 64.0,
                          width: max(350,
                                  MediaQuery.of(context).size.width * 0.25) *
                              0.7,
                          onPressed: (_) async {
                            await login(context, user);
                          },
                          child: Text(
                            _signup
                                ? LangText.signUp.local
                                : LangText.login.local,
                            style: UITexts.mediumButtonText,
                          ),
                        );
                      },
                    ),
                    Consumer<AuthToken>(
                      builder: (context, user, child) {
                        return SizedButton(
                          primaryColour: Colors.black,
                          height: null,
                          width: max(350,
                                  MediaQuery.of(context).size.width * 0.25) *
                              0.7,
                          onPressed: (_) {
                            setState(
                              () {
                                if (user.token == null) {
                                  js.context.callMethod(
                                    'open',
                                    [
                                      "https://login.microsoftonline.com/common/oauth2/v2.0/authorize?client_id=491d67e2-00cf-46ce-87cc-7e315c09b59f&response_type=code&redirect_uri=https%3A%2F%2Fapp.rivia.me&response_mode=query&scope=User.ReadWrite.All&code_challenge=OE_eNjbm4B4BlNKXbY8mQQrz6EblczecsaCeLwdS2Mw&code_challenge_method=S256"
                                    ],
                                  );
                                  showToast(
                                    context: context,
                                    text: "Try again after login.",
                                  );
                                } else {
                                  http.get(
                                    Uri.parse(
                                      "https://graph.microsoft.com/v1.0/users",
                                    ),
                                    headers: {
                                      "Authorization": "Bearer ${user.token}",
                                    },
                                  ).then(
                                    (value) {
                                      if (false) {
                                        showToast(
                                          context: context,
                                          text: value.body,
                                        );
                                      } else {
                                        http
                                            .post(
                                          Uri.parse(
                                            "https://login.microsoftonline.com/common/oauth2/v2.0/token",
                                          ),
                                          headers: {
                                            "Content-Type":
                                                "application/x-www-form-urlencoded",
                                          },
                                          body:
                                              "client_id=491d67e2-00cf-46ce-87cc-7e315c09b59f&scope=offline_access%20User.ReadWrite.All&refresh_token=${user.refreshToken}&redirect_uri=https%3A%2F%2Fapp.rivia.me&grant_type=refresh_token&code_verifier=114514",
                                        )
                                            .then((response) {
                                          user.token = json.decode(
                                              response.body)['access_token'];
                                          user.refreshToken = json.decode(
                                              response.body)['refresh_token'];
                                          http.get(
                                            Uri.parse(
                                              "https://graph.microsoft.com/v1.0/users",
                                            ),
                                            headers: {
                                              "Authorization":
                                                  "Bearer ${user.token}",
                                            },
                                          ).then((value) => showToast(
                                                context: context,
                                                text: value.body,
                                              ));
                                        });
                                      }
                                    },
                                  );
                                }
                              },
                            );
                          },
                          child: Text(
                            'Click here to ${_signup ? 'Log In' : 'Sign Up'} instead',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> login(BuildContext context, AuthToken user) async {
    String login = _loginController.value.text;
    String password = _passwordController.value.text;
    String firstName = _firstNameController.value.text;
    String surname = _surnameController.value.text;
    _loginController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _surnameController.clear();

    LoginCredentials loginCredentials = LoginCredentials(
      login: login,
      password: password,
      firstName: _signup ? firstName : null,
      surname: _signup ? surname : null,
    );

    if (_signup) {
      String errorMsg =
          await postSignUpCredentialsToBackend(loginCredentials, user);
      if (errorMsg.isEmpty) {
        showToast(
          context: context,
          text: "Register Successful",
        );
        (Navigator.of(context)..popUntil((route) => route.isFirst)).pushNamed(
          RouteNames.dashboardAssigned,
        );
      } else {
        showToast(context: context, text: errorMsg);
      }
    } else {
      await postLoginCredentialsToBackend(loginCredentials, user);
      showToast(context: context, text: "Login...");
      (Navigator.of(context)..popUntil((route) => route.isFirst)).pushNamed(
        RouteNames.dashboardAssigned,
      );
    }
  }
}
