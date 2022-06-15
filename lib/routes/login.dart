import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/test_data.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/login_credentials.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/microsoft.dart';
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
  final bool _signup = false;

  @override
  void initState() {
    super.initState();
    getSharedPref(() => setState(() {}));
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
            LanguageSwitcher(callback: () => setState(() => {})),
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
                    SizedButton(
                      backgroundColour: const Color.fromRGBO(239, 198, 135, 1),
                      primaryColour: Colors.black,
                      onPressedColour: const Color.fromRGBO(239, 198, 135, 1),
                      height: 64.0,
                      width:
                          max(350, MediaQuery.of(context).size.width * 0.25) *
                              0.7,
                      onPressed: (_) async {
                        Navigator.of(context).pushNamed(
                          RouteNames.review,
                          arguments: testMeeting2,
                        );
                        // await login(context);
                      },
                      child: Text(
                        _signup ? LangText.signUp.local : LangText.login.local,
                        style: UITexts.mediumButtonText,
                      ),
                    ),
                    SizedButton(
                      primaryColour: Colors.black,
                      height: null,
                      width:
                          max(350, MediaQuery.of(context).size.width * 0.25) *
                              0.7,
                      onPressed: (_) async {
                        if (authToken.token == null) {
                          // Admin Consent
                          // js.context.callMethod(
                          //   'open',
                          //   [
                          //     "https://login.microsoftonline.com/common/adminconsent?client_id=491d67e2-00cf-46ce-87cc-7e315c09b59f&redirect_uri=https%3A%2F%2Fapp.rivia.me"
                          //   ],
                          // );
                          microsoftLogin();
                        } else {
                          await microsoftGetUserId();
                          if (authToken.token == null) {
                            // Admin Consent
                            // js.context.callMethod(
                            //   'open',
                            //   [
                            //     "https://login.microsoftonline.com/common/adminconsent?client_id=491d67e2-00cf-46ce-87cc-7e315c09b59f&redirect_uri=https%3A%2F%2Fapp.rivia.me"
                            //   ],
                            // );
                            microsoftLogin();
                          } else {
                            await microsoftGetUserId();
                            showToast(
                              context: context,
                              text: authToken.tenantDomain ??
                                  "[ERROR: NOT LOGGED IN]",
                            );
                          }
                          final foo = await getMeetings();
                          print(foo);
                          Navigator.of(context).popAndPushNamed(
                            RouteNames.analytics,
                            arguments: [testMeeting, testMeeting2],
                          );
                        }
                      },
                      child: Text(
                        'Click here to ${_signup ? 'Log In' : 'Sign Up'} instead',
                      ),
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

  Future<void> login(BuildContext context) async {
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
      String errorMsg = await postSignUpCredentialsToBackend(loginCredentials);
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
      await postLoginCredentialsToBackend(loginCredentials);
      showToast(context: context, text: "Login...");
      (Navigator.of(context)..popUntil((route) => route.isFirst)).pushNamed(
        RouteNames.dashboardAssigned,
      );
    }
  }
}
