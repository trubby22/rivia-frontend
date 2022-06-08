import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';

List<Participant> testParticipants = [
  Participant(name: "Mamezuku", surname: "Rai", email: "js@rt.cr"),
  Participant(name: "Giorno", surname: "Giovanna", email: "js@kc.tt"),
];

List<Response> testResponses = [
  Response(
    participant: testParticipants[0],
    quality: 114.514,
    painPoints: {'0': "PAINTOS"},
    notNeeded: List.of(testParticipants),
    notPrepared: List.of(testParticipants),
    feedback: "HOT PASSION 暑く強い思い",
  ),
  Response(
    participant: testParticipants[1],
    quality: 114.514,
    painPoints: {'0': "PAINTOS"},
    notNeeded: [testParticipants[0]],
    notPrepared: [testParticipants[0]],
    feedback: "HOT PASSION 暑く強い思い",
  ),
];

Meeting testMeeting = Meeting(
  title: "Bar Meeting",
  meetingId: "114514-1919810",
  startTime: DateTime.now(),
  endTime: DateTime.now(),
  participants: [
    Participant(name: "Mamezuku", surname: "Rai", email: "js@rt.cr"),
    Participant(name: "Giorno", surname: "Giovanna", email: "js@kc.tt"),
  ],
);

Meeting testMeeting2 = Meeting(
  title: "Foo Meeting",
  startTime: DateTime.now(),
  endTime: DateTime.now(),
  participants: [
    Participant(name: "Mamezuku", surname: "Rai", email: "js@rt.cr"),
    Participant(name: "Giorno", surname: "Giovanna", email: "js@kc.tt"),
  ],
  painPoints: {
    '1': 'meeting overran',
    '2': 'meeting too short',
    '3': 'I spoke too little and listened too much',
    '4': 'too many people invited',
  },
);
