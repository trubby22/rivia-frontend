import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/ui_texts.dart';

import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/utilities/bar_graph.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/language_switcher.dart';

class MeetingSummary extends StatefulWidget {
  final Meeting meeting;

  const MeetingSummary({
    Key? key,
    required this.meeting,
  }) : super(key: key);

  @override
  State<MeetingSummary> createState() => _MeetingSummaryState();
}

class _MeetingSummaryState extends State<MeetingSummary> {
  List<Response> _responses = [];

  @override
  void initState() {
    super.initState();
    getSharedPref(() => setState(() {}));
    fetchResponses();
  }

  void fetchResponses() async {
    List<Response> tempResponses = await getMeetingSummary(widget.meeting);
    setState(() {
      _responses = tempResponses;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<Participant, List<Participant>> notNeeded = {};
    Map<Participant, List<Participant>> notPrepared = {};

    for (final response in _responses) {
      for (final participant in response.notNeeded) {
        if (notNeeded.containsKey(participant)) {
          notNeeded[participant]!.add(response.participant);
        } else {
          notNeeded[participant] = [response.participant];
        }
      }
    }

    for (final response in _responses) {
      for (final participant in response.notPrepared) {
        if (notPrepared.containsKey(participant)) {
          notPrepared[participant]!.add(response.participant);
        } else {
          notPrepared[participant] = [response.participant];
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.meeting.title),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await authToken.reset();
              (Navigator.of(context)..popUntil((route) => route.isFirst))
                  .popAndPushNamed(
                RouteNames.login,
              );
            },
            child: Icon(Icons.logout),
          ),
          // ignore: prefer_const_constructors
          LanguageSwitcher(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 80.0),
        child: ListView(
          children: [
            Center(
              child: Text(
                LangText.aggregateStats.local,
                style: UITexts.sectionHeader,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              '${LangText.aggregateParticipants.local}: ${widget.meeting.participants.length}',
              style: UITexts.sectionSubheader,
            ),
            const SizedBox(height: 12.0),
            Text(
              '${LangText.aggregateNotNeeded.local}: ${notNeeded.length}',
              style: UITexts.sectionSubheader,
            ),
            const SizedBox(height: 12.0),
            Text(
              '${LangText.aggregateNotPrepared.local}: ${notPrepared.length}',
              style: UITexts.sectionSubheader,
            ),
            const SizedBox(height: 12.0),
            Center(
              child: Text(
                LangText.detailedStats.local,
                style: UITexts.sectionHeader,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              LangText.detailedNotNeeded.local,
              style: UITexts.sectionSubheader,
            ),
            if (notNeeded.isNotEmpty)
              BarGraph(
                dicts: notNeeded.map(
                  (key, value) => MapEntry(key, value.length),
                ),
                callback: (participant) => notNeeded[participant]
                    ?.map((p) => Text(p.fullName))
                    .toList(),
              ),
            if (notNeeded.isEmpty) Text(LangText.noOneNotNeeded.local),
            const SizedBox(height: 12.0),
            Text(
              LangText.detailedNotPrepared.local,
              style: UITexts.sectionSubheader,
            ),
            if (notPrepared.isNotEmpty)
              BarGraph(
                dicts: notPrepared.map(
                  (key, value) => MapEntry(key, value.length),
                ),
                callback: (participant) => notPrepared[participant]
                    ?.map((p) => Text(p.fullName))
                    .toList(),
              ),
            if (notPrepared.isEmpty) Text(LangText.noOneNotPrepared.local),
          ],
        ),
      ),
    );
  }
}
