import 'package:flutter/material.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/settings.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/microsoft.dart';
import 'dart:html';

class Redirect extends StatefulWidget {
  const Redirect({
    Key? key,
    this.code,
    this.adminConsent,
    this.meetingId,
  }) : super(key: key);
  final String? code;
  final bool? adminConsent;
  final String? meetingId;

  @override
  State<Redirect> createState() => _RedirectState();
}

Future<void> presets(context, String? code) async {
  await microsoftGetUserId(code);
  if (!testMode) {
    window.history.pushState(null, 'home', 'https://app.rivia.me');
  }
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
  (Navigator.of(context)..popUntil((route) => route.isFirst)).pushNamed(
    RouteNames.analytics,
    arguments: meetings.where((m) => m != null).cast<Meeting>().toList(),
  );
}

class _RedirectState extends State<Redirect> {
  Future<void> redirectLogic() async {
    if (widget.meetingId != null) {
      await getSharedPref(null);
      final hasId = await microsoftGetUserId(null);
      if (hasId) {
        final meeting = await getMeetingContent(widget.meetingId!);
        final isReviewed = await getIsReviewed(widget.meetingId!);
        Navigator.of(context).pushNamed(
          isReviewed ? RouteNames.summaryLink : RouteNames.reviewLink,
          arguments: isReviewed ? [meeting!] : meeting!,
        );
      } else {
        authToken.meetingId = widget.meetingId;
        await setSharedPref();
        microsoftLogin();
      }
      return;
    }

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

    if (authToken.meetingId != null) {
      await microsoftGetUserId(widget.code);
      final meeting = await getMeetingContent(authToken.meetingId!);
      final isReviewed = await getIsReviewed(authToken.meetingId!);
      authToken.meetingId = null;
      await setSharedPref();
      Navigator.of(context).pushNamed(
        isReviewed ? RouteNames.summaryLink : RouteNames.reviewLink,
        arguments: isReviewed ? [meeting!] : meeting!,
      );
    } else if (authToken.isAdmin) {
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
