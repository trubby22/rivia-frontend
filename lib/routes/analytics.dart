import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
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
                    border: TableBorder.all(),
                    children: [
                      TableRow(
                        children: [
                          Text(
                            LangText.date.local,
                            textAlign: TextAlign.center,
                            style: UITexts.sectionSubheader,
                          ),
                          Text(
                            LangText.time.local,
                            textAlign: TextAlign.center,
                            style: UITexts.sectionSubheader,
                          ),
                          Text(
                            LangText.organiser.local,
                            textAlign: TextAlign.center,
                            style: UITexts.sectionSubheader,
                          ),
                          Text(
                            LangText.noParticipants.local,
                            textAlign: TextAlign.center,
                            style: UITexts.sectionSubheader,
                          ),
                          Text(
                            LangText.lvlSat.local,
                            textAlign: TextAlign.center,
                            style: UITexts.sectionSubheader,
                          ),
                          Text(
                            LangText.needed.local,
                            textAlign: TextAlign.center,
                            style: UITexts.sectionSubheader,
                          ),
                          Text(
                            LangText.prepared.local,
                            textAlign: TextAlign.center,
                            style: UITexts.sectionSubheader,
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
                            if (p.id == meeting.organiserId) {
                              organiser = p;
                              break;
                            }
                          }
                          final organiserName = organiser?.fullName ?? "[NULL]";

                          return TableRow(
                            children: [
                              Text(
                                '${start.day}/${start.month}/${start.year}',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '${TimeOfDay.fromDateTime(start).format(context)} - ${TimeOfDay.fromDateTime(end).format(context)}',
                                textAlign: TextAlign.center,
                              ),
                              Text(organiserName, textAlign: TextAlign.center),
                              Text(
                                '${meeting.participants.length}',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Soccer',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '11',
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '42',
                                textAlign: TextAlign.center,
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
