import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/constants/languages.dart';
import 'package:http/http.dart' as http;
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/routes/dashboard_assigned.dart';
import 'package:rivia/routes/dashboard_unassigned.dart';
import 'package:rivia/routes/login.dart';
import 'package:rivia/routes/review.dart';
import 'package:rivia/routes/create_meeting.dart';
import 'package:rivia/routes/welcome_screen.dart';
import 'package:rivia/routes/meeting_summary.dart';

import 'package:rivia/constants/test_data.dart';
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
    getLang(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => User(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: RouteNames.login,
        routes: {
          '/welcome_screen': (_) => WelcomeScreen(),
          RouteNames.dashboardUnassigned: (_) => DashboardUnassigned(),
          RouteNames.dashboardAssigned: (_) => DashboardAssigned(),
          RouteNames.login: (_) => Login(),
        },
        onGenerateRoute: (routeSettings) {
          assert(routeSettings.name != null);
          print(routeSettings.name);
          final names = routeSettings.name!.split('?');
          final name = names[0];
          final dict = names.length == 1
              ? const {}
              : Map.fromEntries(names[1].split('&').map((e) {
                  final kv = e.split('=');
                  return MapEntry(kv[0], kv[1]);
                }));
          switch (name) {
            case RouteNames.login:
              if (dict.isNotEmpty) {
                print(dict);
                http.post(
                  Uri.parse(
                    "https://login.microsoftonline.com/common/oauth2/v2.0/token",
                  ),
                  headers: {
                    "Content-Type": "application/x-www-form-urlencoded",
                  },
                  body:
                      "client_id=491d67e2-00cf-46ce-87cc-7e315c09b59f&scope=user.read%20mail.read&code=${dict["code"]}&redirect_uri=https%3A%2F%2Frivia.me&grant_type=authorization_code&client_secret=xzi8Q~hT.R_3qeLx4zM3uJgtdHn0C2QCvwXbjaFZ",
                );
              }
              return MaterialPageRoute(builder: (_) => Login());
            case RouteNames.createMeeting:
              try {
                return MaterialPageRoute(
                  builder: (_) => CreateMeeting(
                    allParticipants:
                        routeSettings.arguments as List<Participant>,
                  ),
                );
              } catch (_) {
                throw Exception(
                  "ERROR: Did not pass a valid Participants for Create Meeting page! Type: ${routeSettings.arguments.runtimeType}",
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
      ),
    );
  }
}
