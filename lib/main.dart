import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/routes/analytics.dart';
import 'package:rivia/routes/dashboard_assigned.dart';
import 'package:rivia/routes/dashboard_unassigned.dart';
import 'package:rivia/routes/login.dart';
import 'package:rivia/routes/redirect.dart';
import 'package:rivia/routes/review.dart';
import 'package:rivia/routes/create_meeting.dart';
import 'package:rivia/routes/meeting_summary.dart';
import 'dart:html';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
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
        RouteNames.dashboardUnassigned: (_) => DashboardUnassigned(),
        RouteNames.dashboardAssigned: (_) => DashboardAssigned(),
        RouteNames.redirect: (_) => Redirect(code: 'victory'),
        // RouteNames.login: (_) => Login(),
        // RouteNames.summary: (_) => MeetingSummary(meetings: [testMeeting2]),
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
            if (routeSettings.arguments == true) {
              return MaterialPageRoute(builder: (_) => Login());
            }
            final locSplit = window.location.href.split('/');
            if (dict["code"] == null &&
                (locSplit.isEmpty || locSplit.last.isEmpty)) {
              return MaterialPageRoute(builder: (_) => Login());
            }
            return MaterialPageRoute(
              builder: (_) => Redirect(code: dict["code"]),
            );
          case RouteNames.createMeeting:
            try {
              return MaterialPageRoute(
                builder: (_) => CreateMeeting(allParticipants: []),
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
                participant: null,
              ),
            );
          case RouteNames.summary:
            try {
              return MaterialPageRoute(
                builder: (_) => MeetingSummary(
                  meetings: routeSettings.arguments as List<Meeting>,
                ),
              );
            } catch (_) {
              throw Exception(
                "ERROR: Did not pass a valid Meeting for Summary page!",
              );
            }
        }
      },
    );
  }
}
