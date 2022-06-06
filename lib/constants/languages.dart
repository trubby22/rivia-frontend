Lang language = Lang.en;

enum Lang {
  en,
  ru,
}

enum LangText {
  hi,
}

extension ExtendedLangText on LangText {
  static const langTexts = {
    LangText.hi: ["Hi", "Привет"]
  };

  String get local => langTexts[this]![language.index];
}
