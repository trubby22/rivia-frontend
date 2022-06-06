import 'package:flutter/material.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/routes/dashboard_assigned.dart';
import 'package:rivia/routes/dashboard_unassigned.dart';
import 'package:rivia/routes/review.dart';
import 'package:rivia/routes/summary.dart';

import 'models/meeting.dart';
import 'models/participant.dart';

void main() {
  runApp(const MyApp());
}

List<Participant> testParticipants = [
  Participant(name: "Jacen", surname: "Solo", email: "js@rt.cr"),
  Participant(name: "Luke", surname: "Skywalker", email: "js@kc.tt"),
];

Meeting testMeeting = Meeting(
  title: "Foo Meeting",
  startTime: DateTime.now(),
  endTime: DateTime.now(),
  participants: testParticipants,
);

List<Response> testResponse = [
  Response(
    participant: testParticipants[0],
    quality: 114.514,
    painPoints: {0: "PAINTOS"},
    notNeeded: List.of(testParticipants),
    notPrepared: List.of(testParticipants),
    feedback: "HOT PASSION 暑く強い思い",
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/summary',
      routes: {
        '/review': (_) => Review(meeting: testMeeting),
        '/dashboard_unassigned': (_) => DashboardUnassigned(),
        '/dashboard_assigned': (_) => DashboardAssigned(),
        '/summary': (_) => Summary(
              meeting: testMeeting,
              responses: testResponse,
            ),
      },
    );
  }
}
