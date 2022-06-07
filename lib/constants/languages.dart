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
  detailedStats,
  detailedNotNeeded,
  detailedNotPrepared,
  noOneNotNeeded,
  noOneNotPrepared,
  voters,

  notNeeded,
  notPrepared,
  all,
  n,
  p,

  dashboard,
  meetingName,
  participants,
  date,
  startTime,
  endTime,
}

extension ExtendedLangText on LangText {
  static const langTexts = {
    LangText.hi: ['Hi', 'Привет'],
    LangText.aggregateStats: ['Aggregate Stats', '嘿嘿啊哈哈哈哈'],
    LangText.aggregateParticipants: ['Number of participants', '嘿嘿啊哈哈哈哈'],
    LangText.aggregateNotNeeded: [
      'Number of people voted as not needed for at least once',
      '嘿嘿啊哈哈哈哈',
    ],
    LangText.aggregateNotPrepared: [
      'Number of people voted as not prepared for at least once',
      '嘿嘿啊哈哈哈哈',
    ],
    LangText.detailedStats: ['Detailed Stats', '嘿嘿啊哈哈哈哈'],
    LangText.detailedNotNeeded: ['People voted as not needed', '嘿嘿啊哈哈哈哈'],
    LangText.detailedNotPrepared: ['People voted as not prepared', '嘿嘿啊哈哈哈哈'],
    LangText.noOneNotNeeded: ['No one voted as not needed', '嘿嘿啊哈哈哈哈'],
    LangText.noOneNotPrepared: ['No one voted as not prepared', '嘿嘿啊哈哈哈哈'],
    LangText.voters: ['Voters', '嘿嘿啊哈哈哈哈'],
    LangText.notNeeded: ['Not Needed', '嘿嘿啊哈哈哈哈'],
    LangText.notPrepared: ['Not Prepared', '嘿嘿啊哈哈哈哈'],
    LangText.all: ['ALL', '嗷'],
    LangText.n: ['N', '恩'],
    LangText.p: ['P', '屁'],
    LangText.dashboard: ['Dashboard', ''],
    LangText.meetingName: ['Meeting Name', ''],
    LangText.participants: ['Participants', ''],
    LangText.date: ['Date', ''],
    LangText.startTime: ['Start Time', ''],
    LangText.endTime: ['End Time', ''],
  };

  String get local => langTexts[this]![language.index];
}
