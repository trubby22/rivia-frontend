import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/meeting_entry.dart';

class DashboardAssigned extends StatefulWidget {
  const DashboardAssigned({Key? key}) : super(key: key);

  @override
  State<DashboardAssigned> createState() => _DashboardAssignedState();
}

class _DashboardAssignedState extends State<DashboardAssigned> {
  List<Meeting> _meetings = [];

  @override
  void initState() {
    super.initState();
    getLang(() => setState(() {}));
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
          Consumer<User>(
            builder: (context, user, child) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteNames.login);
                  user.uuid = null;
                },
                child: Icon(Icons.logout),
              );
            },
          ),
          const LanguageSwitcher(),
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
                        .toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          RouteNames.createMeeting,
                        );
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
