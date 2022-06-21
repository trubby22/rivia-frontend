import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/routes/redirect.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/microsoft.dart';
import 'package:rivia/utilities/sized_button.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    super.initState();
    getSharedPref(null);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(244, 242, 234, 1),
        body: Stack(
          children: [
            Center(
              child: Container(
                width: max(350, MediaQuery.of(context).size.width * 0.25),
                height: max(450.0, MediaQuery.of(context).size.height * 0.55),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(48.0)),
                  boxShadow: const [
                    BoxShadow(offset: Offset(0, 1), blurRadius: 2.0),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LangText.rivia.local, style: UITexts.iconHeader),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.04),
                    SizedButton(
                      backgroundColour: const Color.fromRGBO(239, 198, 135, 1),
                      primaryColour: Colors.black,
                      onPressedColour: const Color.fromRGBO(239, 198, 135, 1),
                      height: 64.0,
                      width:
                          max(350, MediaQuery.of(context).size.width * 0.25) *
                              0.7,
                      onPressed: (_) async {
                        if (authToken.isAdmin == false) {
                          microsoftLoginAdmin();
                        } else {
                          presets(context);
                        }
                      },
                      child: Text(
                        LangText.loginAsAdmin.local,
                        style: UITexts.mediumButtonText,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.width * 0.02),
                    SizedButton(
                      backgroundColour: const Color.fromRGBO(239, 198, 135, 1),
                      primaryColour: Colors.black,
                      onPressedColour: const Color.fromRGBO(239, 198, 135, 1),
                      height: 64.0,
                      width:
                          max(350, MediaQuery.of(context).size.width * 0.25) *
                              0.7,
                      onPressed: (_) {
                        if (authToken.userId == null) {
                          microsoftLogin();
                        } else {
                          dashboard(context);
                        }
                      },
                      child: Text(
                        LangText.loginAsUser.local,
                        style: UITexts.mediumButtonText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            LanguageSwitcher(callback: () => setState(() => {})),
          ],
        ),
      ),
    );
  }
}
