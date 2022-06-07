import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/test_data.dart';
import 'package:rivia/utilities/language_switcher.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getLang(null);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: const [LanguageSwitcher()],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteNames.createMeeting);
                  },
                  child: Text('create meeting')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(RouteNames.review, arguments: testMeeting2);
                  },
                  child: Text('review meeting')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(RouteNames.dashboardAssigned);
                  },
                  child: Text('dashboard assigned')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(RouteNames.dashboardUnassigned);
                  },
                  child: Text('dashboard unassigned')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(RouteNames.summary, arguments: testMeeting2);
                  },
                  child: Text('summary')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/login');
                  },
                  child: Text('login')),
            ),
          ],
        ),
      ),
    );
  }
}
