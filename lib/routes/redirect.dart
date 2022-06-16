import 'package:flutter/material.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/microsoft.dart';
import 'package:rivia/utilities/toast.dart';

class Redirect extends StatefulWidget {
  const Redirect({Key? key, this.code}) : super(key: key);
  final String? code;

  @override
  State<Redirect> createState() => _RedirectState();
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
    final result = await microsoftGetTokens(widget.code!);
    if (result) {
      await microsoftGetUserId();
      await setSharedPref();
      final foo = await getMeetings().onError(
        (error, stackTrace) => Future.value([]),
      );
      final bar = await Future.wait(foo.map((f) => getMeetingContent(f)));
      Navigator.of(context).popAndPushNamed(
        RouteNames.analytics,
        arguments: bar.cast<Meeting>(),
      );
    } else {
      showToast(context: context, text: 'Failed to login!');
    }
  }

  @override
  Widget build(BuildContext context) => Container();
}
