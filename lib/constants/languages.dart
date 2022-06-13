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

  confidentialSurvey,
  bad,
  good,
  needed,
  prepared,
  all,
  yes,
  no,
  additionalComments,
  submit,

  meetings,
  dashboard,
  meetingName,
  participants,
  date,
  time,
  startTime,
  endTime,
  createMeeting,

  signUp,
  login,
  firstName,
  surname,
  email,
  password,

  analytics,
  organiser,
  noParticipants,
  lvlSat,
}

extension LangTextContent on LangText {
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
    LangText.confidentialSurvey: [
      'Confidential Survey',
      'Конфиденциальный опрос',
    ],
    LangText.bad: ['BAD', 'ПЛОХО'],
    LangText.good: ['GOOD', 'ХОРОШИЙ'],
    LangText.needed: ['Needed', 'Нужно'],
    LangText.prepared: ['Prepared', 'Готово'],
    LangText.all: ['ALL', 'все'],
    LangText.yes: ['YES', 'Да'],
    LangText.no: ['NO', 'Нет'],
    LangText.additionalComments: [
      'Additional Feedback',
      'Дополнительные комментарии',
    ],
    LangText.submit: ['Submit', 'Отправлять'],
    LangText.meetings: ['Meetings', 'Встречи'],
    LangText.dashboard: ['Dashboard', 'Приборная доска'],
    LangText.meetingName: ['Meeting Name', 'Название встречи'],
    LangText.participants: ['Participants', 'Участники'],
    LangText.date: ['Date', 'Свидание'],
    LangText.time: ['Time', 'Время'],
    LangText.startTime: ['Start Time', 'Время начала'],
    LangText.endTime: ['End Time', 'Время окончания'],
    LangText.signUp: ['Sign Up', 'Подписаться'],
    LangText.login: ['Login', 'Авторизоваться'],
    LangText.firstName: ['First Name', 'Имя'],
    LangText.surname: ['Surname', 'Фамилия'],
    LangText.email: ['Email', 'Эл. адрес'],
    LangText.password: ['Password', 'Пароль'],
    LangText.createMeeting: ['Create Meeting', 'Создать встречу'],
    LangText.analytics: ['Analytics', 'Аналитика'],
    LangText.organiser: ['Organiser', 'Организатор'],
    LangText.noParticipants: ['Number of Participants', 'Число участников'],
    LangText.lvlSat: [
      'Level of Satisfaction',
      'Число участников',
    ],
  };
}
