import 'package:flutter/material.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/microsoft.dart';
import 'package:rivia/utilities/toast.dart';
import 'dart:html';

class Redirect extends StatefulWidget {
  const Redirect({Key? key, this.code}) : super(key: key);
  final String? code;

  @override
  State<Redirect> createState() => _RedirectState();
}

Future<void> dashboard(context) async {
  await microsoftGetUserId();
  final foo = await getMeetings().onError(
    (error, stackTrace) => Future.value([]),
  );

  final bar = await Future.wait(foo.map((f) => getMeetingContent(f)));
  window.history.pushState(null, 'home', 'https://app.rivia.me');
  Navigator.of(context).popAndPushNamed(
    RouteNames.analytics,
    arguments: bar.cast<Meeting>(),
  );
}

class _RedirectState extends State<Redirect> {
  @override
  void initState() {
    super.initState();
    redirectLogic();
  }

  Future<void> redirectLogic() async {
    if (widget.code == null) {
      return;
    }
    await getSharedPref(null);
    final result = authToken.userId == null
        ? await microsoftGetTokens(widget.code!)
        : true;
    if (result) {
      await microsoftGetUserId();
      final foo = await getMeetings().onError(
        (error, stackTrace) => Future.value([]),
      );

      final bar = await Future.wait(foo.map((f) => getMeetingContent(f)));
      window.history.pushState(null, 'home', 'https://app.rivia.me');
      Navigator.of(context).popAndPushNamed(
        RouteNames.analytics,
        arguments: bar.cast<Meeting>(),
      );
    } else {
      showToast(context: context, text: 'Failed to login!');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color.fromRGBO(244, 242, 234, 1),
        body: Container(),
      );
}
