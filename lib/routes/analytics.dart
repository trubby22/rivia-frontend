import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/language_switcher.dart';

class Analytics extends StatefulWidget {
  const Analytics({Key? key, required this.meetings}) : super(key: key);

  final List<Meeting> meetings;

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  int _highlightIndex = -1;

  Widget entryBuilder(
    BuildContext context, {
    required int index,
    required String text,
  }) {
    return TableRowInkWell(
      onTap: () => Navigator.of(context).pushNamed(
        RouteNames.summary,
        arguments: widget.meetings[index],
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _highlightIndex = index),
        onExit: (_) => setState(() => _highlightIndex = -1),
        child: Container(
          height: 100.0,
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: UITexts.bigText,
            ),
          ),
        ),
      ),
    );
  }

  Widget tableBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Align(
      child: SizedBox(
        width: width * 0.72,
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
            2: IntrinsicColumnWidth(),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Colors.blue),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LangText.date.local,
                    textAlign: TextAlign.center,
                    style: UITexts.bigText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LangText.startTime.local,
                    textAlign: TextAlign.center,
                    style: UITexts.bigText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LangText.endTime.local,
                    textAlign: TextAlign.center,
                    style: UITexts.bigText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LangText.organiser.local,
                    textAlign: TextAlign.center,
                    style: UITexts.bigText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LangText.noParticipants.local,
                    textAlign: TextAlign.center,
                    style: UITexts.bigText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LangText.lvlSat.local,
                    textAlign: TextAlign.center,
                    style: UITexts.bigText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LangText.neededParticipants.local,
                    textAlign: TextAlign.center,
                    style: UITexts.bigText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    LangText.preparedParticipants.local,
                    textAlign: TextAlign.center,
                    style: UITexts.bigText.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            ...List.generate(
              widget.meetings.length,
              (index) {
                final meeting = widget.meetings[index];
                final start = meeting.startTime;
                final end = meeting.endTime;
                Participant? organiser;
                for (final p in meeting.participants) {
                  if (p.participant.id == meeting.organiserId) {
                    organiser = p.participant;
                    break;
                  }
                }
                final organiserName = organiser?.fullName ?? "[NULL]";
                final participantNum = meeting.participants.length;
                final notNeededNum =
                    meeting.participants.where((e) => e.notNeeded != 0).length;
                final notPreparedNum = meeting.participants
                    .where((e) => e.notPrepared != 0)
                    .length;

                return TableRow(
                  decoration: BoxDecoration(
                    color: _highlightIndex == index
                        ? index.isOdd
                            ? Colors.blue.shade50
                            : Colors.orange.shade50
                        : index.isOdd
                            ? const Color.fromARGB(255, 150, 210, 255)
                            : const Color.fromARGB(255, 255, 212, 150),
                  ),
                  children: [
                    entryBuilder(
                      context,
                      index: index,
                      text: '${start.day}/${start.month}/${start.year}',
                    ),
                    entryBuilder(
                      context,
                      index: index,
                      text: TimeOfDay.fromDateTime(start).format(context),
                    ),
                    entryBuilder(
                      context,
                      index: index,
                      text: TimeOfDay.fromDateTime(end).format(context),
                    ),
                    entryBuilder(
                      context,
                      index: index,
                      text: organiserName,
                    ),
                    entryBuilder(
                      context,
                      index: index,
                      text: '$participantNum',
                    ),
                    entryBuilder(
                      context,
                      index: index,
                      text: '${(meeting.quality * 100).round()}%',
                    ),
                    entryBuilder(
                      context,
                      index: index,
                      text: '${participantNum - notNeededNum}',
                    ),
                    entryBuilder(
                      context,
                      index: index,
                      text: '${participantNum - notPreparedNum}',
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget foregroundBuilder(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ListView(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.04),
            child: Text(
              LangText.analytics.local,
              style: UITexts.iconHeader,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: min(width * 0.07, max(0, width - 700)),
            right: min(width * 0.07, max(0, width - 700)),
            bottom: max(height * 0.05, 20.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          decoration: const BoxDecoration(
            color: Color(0xFFE6E6E6),
            borderRadius: BorderRadius.all(Radius.circular(48.0)),
            boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 2.0)],
          ),
          child: Column(
            children: [
              Align(
                child: Padding(
                  padding: EdgeInsets.only(top: height * 0.06),
                  // width: width * 0.72,
                  child: //TODO
                      Container(
                    color: Colors.red,
                    height: 100,
                  ),
                ),
              ),
              tableBuilder(context),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/general_bg.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          foregroundBuilder(context),
          LanguageSwitcher(callback: () => setState(() => {})),
        ],
      ),
    );
  }
}
