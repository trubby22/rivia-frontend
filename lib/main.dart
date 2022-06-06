import 'package:flutter/material.dart';
import 'package:rivia/routes/create_meeting.dart';
import 'package:rivia/routes/dashboard_assigned.dart';
import 'package:rivia/routes/dashboard_unassigned.dart';
import 'package:rivia/helper_widgets/date_picker.dart';
import 'package:rivia/routes/review.dart';
import 'package:rivia/routes/welcome_screen.dart';

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
      initialRoute: '/welcome_screen',
      routes: {
        '/review': (_) => Review(meeting: testMeeting),
        '/dashboard_unassigned': (_) => DashboardUnassigned(),
        '/dashboard_assigned': (_) => DashboardAssigned(),
        '/create_meeting': (_) => CreateMeeting(),
        '/welcome_screen': (_) => WelcomeScreen(),
      },
    );
  }
}
