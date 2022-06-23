import 'package:flutter/material.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/settings.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/microsoft.dart';
import 'dart:html';

class Redirect extends StatefulWidget {
  const Redirect({Key? key, this.code, this.adminConsent}) : super(key: key);
  final String? code;
  final bool? adminConsent;

  @override
  State<Redirect> createState() => _RedirectState();
}

Future<void> presets(context, String? code) async {
  await microsoftGetUserId(code);
  if (!testMode) {
    window.history.pushState(null, 'home', 'https://app.rivia.me');
  }
  await postPresets(null);
  final presets = await getPresets();
  Navigator.of(context).popAndPushNamed(RouteNames.presets, arguments: presets);
}

Future<void> dashboard(context, String? code) async {
  await microsoftGetUserId(code);
  final meetingIds = await getMeetings().onError(
    (error, stackTrace) => Future.value([]),
  );

  final meetings =
      await Future.wait(meetingIds.map((f) => getMeetingContent(f)));
  if (!testMode) {
    window.history.pushState(null, 'home', 'https://app.rivia.me');
  }
  Navigator.of(context).popAndPushNamed(
    RouteNames.analytics,
    arguments: meetings.cast<Meeting>(),
  );
}

class _RedirectState extends State<Redirect> {
  Future<void> redirectLogic() async {
    if (widget.code == null) {
      if (widget.adminConsent != true) {
        return;
      }
      authToken.isAdmin = true;
      await setSharedPref();
      microsoftLogin();
      return;
    }
    await getSharedPref(null);
    // final result = authToken.userId == null
    //     ? await microsoftGetTokens(widget.code!)
    //     : true;

    if (authToken.isAdmin) {
      presets(context, widget.code);
    } else {
      dashboard(context, widget.code);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color.fromRGBO(244, 242, 234, 1),
        body: FutureBuilder(
          future: redirectLogic(),
          builder: (context, snapshot) {
            return Container();
          },
        ),
      );
}
