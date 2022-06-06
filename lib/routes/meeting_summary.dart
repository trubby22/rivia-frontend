import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/ui_texts.dart';

import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/utilities/bar_graph.dart';

List<Participant> _testParticipants = [
  Participant(name: "Jacen", surname: "Solo", email: "js@rt.cr"),
  Participant(name: "Luke", surname: "Skywalker", email: "js@kc.tt"),
];

List<Response> _testResponses = [
  Response(
    participant: _testParticipants[0],
    quality: 114.514,
    painPoints: {0: "PAINTOS"},
    notNeeded: List.of(_testParticipants),
    notPrepared: List.of(_testParticipants),
    feedback: "HOT PASSION 暑く強い思い",
  ),
  Response(
    participant: _testParticipants[1],
    quality: 114.514,
    painPoints: {0: "PAINTOS"},
    notNeeded: [_testParticipants[0]],
    notPrepared: [_testParticipants[0]],
    feedback: "HOT PASSION 暑く強い思い",
  ),
];

class MeetingSummary extends StatelessWidget {
  final Meeting meeting;

  MeetingSummary({
    Key? key,
    required this.meeting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<Participant, List<Participant>> notNeeded = {};
    Map<Participant, List<Participant>> notPrepared = {};

    for (final response in _testResponses) {
      for (final participant in response.notNeeded) {
        if (notNeeded.containsKey(participant)) {
          notNeeded[participant]!.add(response.participant);
        } else {
          notNeeded[participant] = [response.participant];
        }
      }
    }

    for (final response in _testResponses) {
      for (final participant in response.notPrepared) {
        if (notPrepared.containsKey(participant)) {
          notPrepared[participant]!.add(response.participant);
        } else {
          notPrepared[participant] = [response.participant];
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(meeting.title)),
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
              '${LangText.aggregateParticipants.local}: ${meeting.participants.length}',
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