import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/routes/analytics.dart';
import 'package:rivia/routes/dashboard_assigned.dart';
import 'package:rivia/routes/dashboard_unassigned.dart';
import 'package:rivia/routes/login.dart';
import 'package:rivia/routes/review.dart';
import 'package:rivia/routes/create_meeting.dart';
import 'package:rivia/routes/meeting_summary.dart';
import 'package:rivia/routes/welcome_screen.dart';

import 'package:rivia/constants/test_data.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/microsoft.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> setUpSharedPref() async {
    final sharedPref = await SharedPreferences.getInstance();
    if (sharedPref.getInt(Fields.lang) == null) {
      sharedPref.setInt(Fields.lang, Lang.en.index);
    }
  }

  @override
  void initState() {
    super.initState();
    setUpSharedPref();
    getSharedPref(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RouteNames.login,
      routes: {
        '/welcome_screen': (_) => WelcomeScreen(),
        RouteNames.dashboardUnassigned: (_) => DashboardUnassigned(),
        RouteNames.dashboardAssigned: (_) => DashboardAssigned(),
        RouteNames.login: (_) => Login(),
        // RouteNames.summary: (_) => MeetingSummary(meeting: testMeeting2),
        RouteNames.analytics: (_) =>
            Analytics(meetings: [testMeeting, testMeeting2]),
      },
      onGenerateRoute: (routeSettings) {
        assert(routeSettings.name != null);
        final names = routeSettings.name!.split('?');
        final name = names[0];
        final dict = names.length == 1
            ? const {}
            : Map.fromEntries(names[1].split('&').map((e) {
                final kv = e.split('=');
                return MapEntry(kv[0], kv[1]);
              }));
        switch (name) {
          case RouteNames.analytics:
            try {
              return MaterialPageRoute(
                builder: (_) => Analytics(
                  meetings: routeSettings.arguments as List<Meeting>,
                ),
              );
            } catch (_) {
              throw Exception(
                "ERROR: Did not pass a valid list of Meetings for Analytics page! Type: ${routeSettings.arguments.runtimeType}",
              );
            }
          case RouteNames.login:
            if (dict.isNotEmpty) {
              microsoftGetTokens(dict["code"]);
            }
            return MaterialPageRoute(builder: (_) => Login());
          case RouteNames.createMeeting:
            try {
              return MaterialPageRoute(
                builder: (_) => CreateMeeting(
                  allParticipants: routeSettings.arguments as List<Participant>,
                ),
              );
            } catch (_) {
              throw Exception(
                "ERROR: Did not pass a valid list of Participants for Create Meeting page! Type: ${routeSettings.arguments.runtimeType}",
              );
            }
          case RouteNames.review:
            if (routeSettings.arguments.runtimeType != Meeting) {
              throw Exception(
                "ERROR: Did not pass a valid Meeting for Review page!",
              );
            }
            return MaterialPageRoute(
              builder: (_) => Review(
                meeting: routeSettings.arguments as Meeting,
                participant: testParticipants[0],
              ),
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
