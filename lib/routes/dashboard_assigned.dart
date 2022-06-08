import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/meeting_entry.dart';
import 'package:rivia/utilities/sized_button.dart';

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
        title: Text(LangText.dashboard.local),
        actions: [
          Consumer<User>(
            builder: (context, user, child) {
              return ElevatedButton(
                onPressed: () {
                  (Navigator.of(context)..popUntil((route) => route.isFirst))
                      .popAndPushNamed(
                    RouteNames.login,
                  );
                  user.uuid = null;
                },
                child: Icon(Icons.logout),
              );
            },
          ),
          // ignore: prefer_const_constructors
          LanguageSwitcher(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Expanded(child: SizedBox()),
            Container(
              width: 400,
              child: Column(
                children: [
                  Text(LangText.meetings.local, style: UITexts.sectionHeader),
                  const SizedBox(height: 16.0),
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
                  SizedButton(
                    width: null,
                    height: null,
                    onPressed: (_) {
                      Navigator.of(context).pushNamed(
                        RouteNames.createMeeting,
                      );
                    },
                    isSelected: true,
                    child: Text(
                      LangText.createMeeting.local,
                      style: UITexts.mediumButtonText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
