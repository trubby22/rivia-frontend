import 'package:flutter/material.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';

Meeting _testMeeting = Meeting(
  title: "Bar Meeting",
  startTime: DateTime.now(),
  endTime: DateTime.now(),
  participants: [
    Participant(name: "Jacen", surname: "Solo", email: "js@rt.cr"),
    Participant(name: "Luke", surname: "Skywalker", email: "js@kc.tt"),
  ],
);

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          ElevatedButton(onPressed: () {}, child: Icon(Icons.flag)),
        ],
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
                        .pushNamed(RouteNames.review, arguments: _testMeeting);
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
                        .pushNamed(RouteNames.summary, arguments: _testMeeting);
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
