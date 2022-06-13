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
    Participant(name: "Mamezuku", surname: "Rai", email: ""),
    Participant(
      name: "Albus Percival Wulfric Brian",
      surname: "Dumbledore",
      email: "",
    ),
    Participant(name: "Yui", surname: "Kusano", email: ""),
    Participant(name: "Shadow Mistress", surname: "Yuko", email: ""),
    Participant(name: "Jacen", surname: "Syndulla", email: ""),
    Participant(name: "Piotr", surname: "Błaszyk", email: ""),
  ],
  painPoints: {
    '1': 'Need clearer, finer agenda',
    '2': 'Meeting is too long',
    '3': 'Follow-ups should be discussed at the next meeting',
    '4': 'Did not have time to prepare for the meeting',
  },
);
