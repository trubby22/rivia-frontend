import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';

List<Participant> testParticipants = [
  Participant(name: "Mamezuku", surname: "Rai", email: "js@rt.cr", id: "0"),
  Participant(name: "Giorno", surname: "Giovanna", email: "js@kc.tt", id: "1"),
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
  qualities: [0.5, 0.6],
  responses: 2,
  meetingId: "114514-1919810",
  organiserId: "3",
  startTime: DateTime.now(),
  endTime: DateTime.now(),
  participants: [
    TaggedParticipant(
      participant: Participant(name: "Mamezuku", surname: "Rai", id: "2"),
      notNeeded: 1,
      notPrepared: 2,
    ),
    TaggedParticipant(
      participant: Participant(name: "Giorno", surname: "Giovanna", id: "3"),
      notNeeded: 0,
      notPrepared: 0,
    ),
  ],
);

Meeting testMeeting2 = Meeting(
  title: "Foo Meeting",
  meetingId: "132452",
  qualities: [0.8, 1.0, 0.4],
  responses: 5,
  startTime: DateTime(2022, 6, 14, 8),
  organiserId: "5",
  endTime: DateTime(2022, 6, 14, 11),
  feedback: [
    'CEO should be fired',
    'Excellent',
    'Great',
    'Too long',
    'No one was prepared',
    'CEO should be fired',
    'Excellent',
    'Great',
    'Too long',
    '3.141592653589793238462643383279502884197',
    'CEO should be fired; CEO should be fired; CEO should be fired',
    'Excellent',
    'Great DAZE!',
    'Too long',
    'No one was prepared',
  ],
  participants: [
    TaggedParticipant(
      participant: Participant(
        name: "Mamezuku",
        surname: "Rai",
        id: "4",
      ),
      notNeeded: 1,
      notPrepared: 2,
    ),
    TaggedParticipant(
      participant: Participant(
        name: "Albus Percival Wulfric Brian",
        surname: "Dumbledore",
        id: "5",
      ),
      notNeeded: 0,
      notPrepared: 0,
    ),
    TaggedParticipant(
      participant: Participant(
        name: "Yui",
        surname: "Kusano",
        id: "5",
      ),
      notNeeded: 0,
      notPrepared: 2,
    ),
    TaggedParticipant(
      participant: Participant(
        name: "Shadow Mistress",
        surname: "Yuko",
        id: "6",
      ),
      notNeeded: 0,
      notPrepared: 3,
    ),
    TaggedParticipant(
      participant: Participant(
        name: "Jacen",
        surname: "Syndulla",
        id: "7",
      ),
      notNeeded: 4,
      notPrepared: 0,
    ),
    TaggedParticipant(
      participant: Participant(
        name: "Piotr",
        surname: "Błaszyk",
        id: "8",
      ),
      notNeeded: 0,
      notPrepared: 0,
    ),
  ],
  painPoints: {
    '1': 'Need clearer, finer agenda',
    '2': 'Meeting is too long',
    '3': 'Follow-ups should be discussed at the next meeting',
    '4': 'Did not have time to prepare for the meeting',
  },
);
