import 'package:clicker/routes/review.dart';
import 'package:flutter/material.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Review(meeting: testMeeting),
      },
    );
  }
}
