import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language switched, please refresh'),
            action: SnackBarAction(
              label: 'hide',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      },
      child: Text(LangText.langCode.local),
    );
  }
}
