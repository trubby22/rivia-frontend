Lang language = Lang.en;

enum Lang {
  en,
  ru,
}

enum LangText {
  langCode,
  langSwitchMsg,
  rivia,

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

  rateQuality,
  notNeeded,
  notPrepared,
  all,
  n,
  p,
  additionalComments,
  submitReview,

  meetings,
  dashboard,
  meetingName,
  participants,
  date,
  startTime,
  endTime,
  createMeeting,

  signUp,
  login,
  firstName,
  surname,
  email,
  password,
}

extension ExtendedLangText on LangText {
  static const langTexts = {
    LangText.langCode: ['EN', 'РУ'],
    LangText.langSwitchMsg: [
      'Language switched, please refresh the page',
      'Язык изменен, обновите страницу',
    ],
    LangText.rivia: [
      'RIVIA',
      'РИВИЯ',
    ],
    LangText.aggregateStats: ['Aggregate Stats', 'Совокупная статистика'],
    LangText.aggregateParticipants: [
      'Number of participants',
      'Число участников',
    ],
    LangText.aggregateNotNeeded: [
      'Number of people voted as not needed for at least once',
      'Количество людей, хотя бы раз проголосовавших за ненадобность',
    ],
    LangText.aggregateNotPrepared: [
      'Number of people voted as not prepared for at least once',
      'Количество человек, хотя бы раз проголосовавших за неподготовленность',
    ],
    LangText.detailedStats: ['Detailed Stats', 'Подробная статистика'],
    LangText.detailedNotNeeded: [
      'People voted as not needed',
      'Люди проголосовали за ненадобность'
    ],
    LangText.detailedNotPrepared: [
      'People voted as not prepared',
      'Люди проголосовали как не готовые'
    ],
    LangText.noOneNotNeeded: [
      'No one voted as not needed',
      'Никто не проголосовал за ненадобность'
    ],
    LangText.noOneNotPrepared: [
      'No one voted as not prepared',
      'Никто не проголосовал как не готовый'
    ],
    LangText.voters: ['Voters', 'Избиратели'],
    LangText.rateQuality: [
      'Rate the meeting quality',
      'Оцените качество встречи',
    ],
    LangText.notNeeded: ['Not Needed', 'Не нужно'],
    LangText.notPrepared: ['Not Prepared', 'Не готово'],
    LangText.all: ['ALL', 'все'],
    LangText.n: ['N', 'Н'],
    LangText.p: ['P', 'Г'],
    LangText.additionalComments: [
      'Additional Comments',
      'Дополнительные комментарии',
    ],
    LangText.submitReview: ['Submit Review', 'Добавить отзыв'],
    LangText.meetings: ['Meetings', 'Встречи'],
    LangText.dashboard: ['Dashboard', 'Приборная доска'],
    LangText.meetingName: ['Meeting Name', 'Название встречи'],
    LangText.participants: ['Participants', 'Участники'],
    LangText.date: ['Date', 'Свидание'],
    LangText.startTime: ['Start Time', 'Время начала'],
    LangText.endTime: ['End Time', 'Время окончания'],
    LangText.signUp: ['Sign Up', 'Подписаться'],
    LangText.login: ['Login', 'Авторизоваться'],
    LangText.firstName: ['First Name', 'Имя'],
    LangText.surname: ['Surname', 'Фамилия'],
    LangText.email: ['Email', 'Эл. адрес'],
    LangText.password: ['Password', 'Пароль'],
    LangText.createMeeting: ['Create Meeting', 'Создать встречу'],
  };

  String get local => langTexts[this]![language.index];
}
