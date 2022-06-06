import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';

import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/utilities/bar_graph.dart';

class Summary extends StatelessWidget {
  final Meeting meeting;
  final List<Response> responses;

  Summary({
    Key? key,
    required this.meeting,
    required this.responses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<Participant, int> notNeeded = {};
    Map<Participant, int> notPrepared = {};

    for (final response in responses) {
      for (final participant in response.notNeeded) {
        if (notNeeded.containsKey(participant)) {
          notNeeded[participant] = notNeeded[participant]! + 1;
        } else {
          notNeeded[participant] = 1;
        }
      }
    }

    for (final response in responses) {
      for (final participant in response.notNeeded) {
        if (notPrepared.containsKey(participant)) {
          notPrepared[participant] = notPrepared[participant]! + 1;
        } else {
          notPrepared[participant] = 1;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(meeting.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text(LangText.aggregateStats.local),
            Text(
              '${LangText.aggregateParticipants.local}: ${meeting.participants.length}',
            ),
            Text('${LangText.aggregateNotNeeded.local}: ###'),
            Text('${LangText.aggregateNotPrepared.local}: ###'),
            BarGraph(dicts: notNeeded),
            BarGraph(dicts: notPrepared),
          ],
        ),
      ),
    );
  }
}
