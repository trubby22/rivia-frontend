import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/utilities/toast.dart';
import 'package:rivia/utilities/change_notifiers.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (authToken.language == Lang.en) {
          authToken.language == Lang.ru;
        } else {
          authToken.language == Lang.en;
        }
        await setSharedPref();
        showToast(context: context, text: 'Language switched, please refresh');
      },
      child: Text(LangText.langCode.local),
    );
  }
}
