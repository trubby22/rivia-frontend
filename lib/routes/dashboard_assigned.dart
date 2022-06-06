import 'package:flutter/material.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/meeting_entry.dart';

Meeting _testMeeting = Meeting(
  title: "Bar Meeting",
  startTime: DateTime.now(),
  endTime: DateTime.now(),
  participants: [
    Participant(name: "Jacen", surname: "Solo", email: "js@rt.cr"),
    Participant(name: "Luke", surname: "Skywalker", email: "js@kc.tt"),
  ],
);

class DashboardAssigned extends StatelessWidget {
  const DashboardAssigned({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          ElevatedButton(onPressed: () {}, child: Icon(Icons.flag)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Spacer(),
            Expanded(
              child: Column(
                children: [
                  Text('Meetings'),
                  Column(children: [MeetingEntry(meeting: _testMeeting)]),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/create_meeting');
                      },
                      child: Text('Create new meeting')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
