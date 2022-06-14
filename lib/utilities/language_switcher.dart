import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/utilities/sized_button.dart';
import 'package:rivia/utilities/change_notifiers.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({Key? key, this.callback}) : super(key: key);

  final Function()? callback;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 64.0,
      top: 24.0,
      child: SizedButton(
        backgroundColour: const Color.fromRGBO(239, 198, 135, 1),
        primaryColour: Colors.black,
        onPressedColour: const Color.fromRGBO(239, 198, 135, 1),
        height: 48.0,
        width: 64.0,
        onPressed: (_) async {
          if (authToken.language == Lang.en) {
            authToken.language = Lang.ru;
          } else {
            authToken.language = Lang.en;
          }
          await setSharedPref();
          callback?.call();
        },
        child: Text(
          LangText.langCode.local,
          style: UITexts.mediumButtonText,
        ),
      ),
    );
  }
}
