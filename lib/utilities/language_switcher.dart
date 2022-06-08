import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/utilities/toast.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (language == Lang.en) {
          await setLang(Lang.ru);
        } else {
          await setLang(Lang.en);
        }

        showToast(context: context, text: 'Language switched, please refresh');
      },
      child: Text(LangText.langCode.local),
    );
  }
}
