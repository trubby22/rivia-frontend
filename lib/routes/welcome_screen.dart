import 'package:flutter/material.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/test_data.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/language_switcher.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    getSharedPref(null);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Dashboard'),
        // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
        actions: [LanguageSwitcher()],
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
                        .pushNamed(RouteNames.summaryOld, arguments: testMeeting2);
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RouteNames.summary);
                  },
                  child: Text('pie chart summary')),
            ),
          ],
        ),
      ),
    );
  }
}
