import 'package:flutter/material.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/meeting_entry.dart';

class DashboardAssigned extends StatefulWidget {
  DashboardAssigned({Key? key}) : super(key: key);

  @override
  State<DashboardAssigned> createState() => _DashboardAssignedState();
}

class _DashboardAssignedState extends State<DashboardAssigned> {
  List<Meeting> _meetings = [];

  @override
  void initState() {
    super.initState();
    print('Fetching meetings');
    fetchMeetings();
  }

  void fetchMeetings() async {
    List<Meeting> tempMeetings = await getMeetings();
    setState(() {
      _meetings = tempMeetings;
    });
  }

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
                  Column(
                      children: _meetings
                          .map((meeting) => MeetingEntry(meeting: meeting))
                          .toList()),
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
