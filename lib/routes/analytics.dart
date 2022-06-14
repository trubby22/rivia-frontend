import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/mouse_clicker.dart';

class Analytics extends StatefulWidget {
  const Analytics({Key? key, required this.meetings}) : super(key: key);

  final List<Meeting> meetings;

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  int _highlightIndex = -1;

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
                child: SizedBox(
                  width: width * 0.68,
                  child: Table(
                    border: TableBorder.all(color: Colors.grey),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: IntrinsicColumnWidth(),
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
                              LangText.time.local,
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
                          final notNeededNum = meeting.participants
                              .where((e) => e.notNeeded != 0)
                              .length;
                          final notPreparedNum = meeting.participants
                              .where((e) => e.notPrepared != 0)
                              .length;

                          return TableRow(
                            decoration: BoxDecoration(
                              color: _highlightIndex == index
                                  ? Colors.white
                                  : index.isEven
                                      ? Colors.blue.shade100
                                      : Colors.blue.shade50,
                            ),
                            children: [
                              MouseClicker(
                                onHover: (_) => setState(
                                  () => _highlightIndex = index,
                                ),
                                // onTap: (_),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${start.day}/${start.month}/${start.year}',
                                    textAlign: TextAlign.center,
                                    style: UITexts.bigText,
                                  ),
                                ),
                              ),
                              MouseClicker(
                                onHover: (_) => setState(
                                  () => _highlightIndex = index,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${TimeOfDay.fromDateTime(start).format(context)}\n${TimeOfDay.fromDateTime(end).format(context)}',
                                    textAlign: TextAlign.center,
                                    style: UITexts.bigText,
                                  ),
                                ),
                              ),
                              MouseClicker(
                                onHover: (_) => setState(
                                  () => _highlightIndex = index,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    organiserName,
                                    textAlign: TextAlign.center,
                                    style: UITexts.bigText,
                                  ),
                                ),
                              ),
                              MouseClicker(
                                onHover: (_) => setState(
                                  () => _highlightIndex = index,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '$participantNum',
                                    textAlign: TextAlign.center,
                                    style: UITexts.bigText,
                                  ),
                                ),
                              ),
                              MouseClicker(
                                onHover: (_) => setState(
                                  () => _highlightIndex = index,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${(meeting.quality * 100).round()}%',
                                    textAlign: TextAlign.center,
                                    style: UITexts.bigText,
                                  ),
                                ),
                              ),
                              MouseClicker(
                                onHover: (_) => setState(
                                  () => _highlightIndex = index,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${participantNum - notNeededNum}',
                                    textAlign: TextAlign.center,
                                    style: UITexts.bigText,
                                  ),
                                ),
                              ),
                              MouseClicker(
                                onHover: (_) => setState(
                                  () => _highlightIndex = index,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${participantNum - notPreparedNum}',
                                    textAlign: TextAlign.center,
                                    style: UITexts.bigText,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
