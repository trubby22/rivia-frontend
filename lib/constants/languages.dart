Lang language = Lang.en;

enum Lang {
  en,
  ru,
}

enum LangText {
  hi,

  aggregateStats,
  aggregateParticipants,
  aggregateNotNeeded,
  aggregateNotPrepared,
}

extension ExtendedLangText on LangText {
  static const langTexts = {
    LangText.hi: ['Hi', 'Привет'],
    LangText.aggregateStats: ['Aggregate Stats', '嘿嘿啊哈哈哈哈'],
    LangText.aggregateParticipants: ['Number of participants', '嘿嘿啊哈哈哈哈'],
    LangText.aggregateNotNeeded: [
      'Numer of people voted as not needed for at least once',
      '嘿嘿啊哈哈哈哈',
    ],
    LangText.aggregateNotPrepared: [
      'Numer of people voted as not prepared for at least once',
      '嘿嘿啊哈哈哈哈',
    ],
  };

  String get local => langTexts[this]![language.index];
}
