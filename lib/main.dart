import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'package:rivia/constants/route_names.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/routes/dashboard_assigned.dart';
import 'package:rivia/routes/dashboard_unassigned.dart';
import 'package:rivia/routes/review.dart';
import 'package:rivia/routes/create_meeting.dart';
import 'package:rivia/routes/dashboard_assigned.dart';
import 'package:rivia/routes/dashboard_unassigned.dart';
import 'package:rivia/routes/login.dart';
import 'package:rivia/routes/review.dart';
import 'package:rivia/routes/welcome_screen.dart';
import 'package:rivia/routes/meeting_summary.dart';

import 'models/meeting.dart';
import 'models/participant.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
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
        '/welcome_screen': (_) => WelcomeScreen(),
        RouteNames.dashboardUnassigned: (_) => DashboardUnassigned(),
        RouteNames.dashboardAssigned: (_) => DashboardAssigned(),
        RouteNames.createMeeting: (_) =>
            CreateMeeting(allParticipants: testParticipants),
        RouteNames.login: (_) => Login(),
      },
      onGenerateRoute: (routeSettings) {
        switch (routeSettings.name) {
          case RouteNames.review:
            if (routeSettings.arguments.runtimeType != Meeting) {
              throw Exception(
                "ERROR: Did not pass a valid Meeting for Review page!",
              );
            }
            return MaterialPageRoute(
              builder: (_) =>
                  Review(meeting: routeSettings.arguments as Meeting),
            );
          case RouteNames.summary:
            if (routeSettings.arguments.runtimeType != Meeting) {
              throw Exception(
                "ERROR: Did not pass a valid Meeting for Summary page!",
              );
            }
            return MaterialPageRoute(
              builder: (_) => MeetingSummary(
                meeting: routeSettings.arguments as Meeting,
              ),
            );
        }
      },
    );
  }
}
