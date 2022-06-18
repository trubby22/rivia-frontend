import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/bar_graph.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:rivia/utilities/log_out_button.dart';
import 'package:rivia/utilities/sized_button.dart';

class MeetingSummary extends StatefulWidget {
  const MeetingSummary({Key? key, required this.meetings}) : super(key: key);

  final List<Meeting> meetings;

  @override
  State<MeetingSummary> createState() => _MeetingSummaryState();
}

class _MeetingSummaryState extends State<MeetingSummary> {
  int _selectedIndex = 0;

  Widget pieChartBuilder(BuildContext context) {
    return PieChart(
      dataMap: binQualityReviews(widget.meetings),
      chartRadius: MediaQuery.of(context).size.width / 4,
      initialAngleInDegree: 270,
      chartValuesOptions: const ChartValuesOptions(
        showChartValuesInPercentage: true,
        decimalPlaces: 0,
      ),
      colorList: [
        Colors.green,
        Colors.green.shade200,
        Colors.yellow,
        Colors.orange,
        Colors.red,
      ],
    );
  }

  Widget barGraphBuilder(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final allParticipants = <Participant>{};

    for (final m in widget.meetings) {
      allParticipants.addAll(m.participants.map((p) => p.participant));
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: min(width * 0.02, max(0, width - 700)),
                  right: min(width * 0.01, max(0, width - 700)),
                  bottom: max(height * 0.05, 20.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                  boxShadow: const [
                    BoxShadow(offset: Offset(0, 1), blurRadius: 2.0),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.02),
                    Text(
                      LangText.detailedNotNeeded.local,
                      style: UITexts.sectionSubheader,
                    ),
                    BarGraph(
                      responseCount: Map.fromEntries(
                        allParticipants.map((p) => MapEntry(
                            p,
                            widget.meetings
                                .where((m) => m.participants
                                    .map((p) => p.participant)
                                    .contains(p))
                                .map((m) => m.responses)
                                .fold<int>(0, (x, y) => x + y))),
                      ),
                      dicts: Map.fromEntries(
                        widget.meetings
                            .map((e) => e.participants)
                            .expand((element) => element)
                            .map((p) => MapEntry(p.participant, p.notNeeded))
                            .where((p) => p.value != 0),
                      ).group(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: min(width * 0.01, max(0, width - 400)),
                  right: min(width * 0.02, max(0, width - 400)),
                  bottom: max(height * 0.05, 20.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                  boxShadow: const [
                    BoxShadow(offset: Offset(0, 1), blurRadius: 2.0),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.02),
                    Text(
                      LangText.detailedNotPrepared.local,
                      style: UITexts.sectionSubheader,
                    ),
                    BarGraph(
                      responseCount: Map.fromEntries(
                        allParticipants.map((p) => MapEntry(
                            p,
                            widget.meetings
                                .where((m) => m.participants
                                    .map((p) => p.participant)
                                    .contains(p))
                                .map((m) => m.responses)
                                .fold<int>(0, (x, y) => x + y))),
                      ),
                      dicts: Map.fromEntries(
                        widget.meetings
                            .map((e) => e.participants)
                            .expand((element) => element)
                            .map((p) => MapEntry(p.participant, p.notPrepared))
                            .where((p) => p.value != 0),
                      ).group(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: min(width * 0.02, max(0, width - 700)),
                  right: min(width * 0.01, max(0, width - 700)),
                  bottom: max(height * 0.05, 20.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                  boxShadow: const [
                    BoxShadow(offset: Offset(0, 1), blurRadius: 2.0),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.02),
                    Text(
                      LangText.detailedNeeded.local,
                      style: UITexts.sectionSubheader,
                    ),
                    BarGraph(
                      responseCount: Map.fromEntries(
                        allParticipants.map((p) => MapEntry(
                            p,
                            widget.meetings
                                .where((m) => m.participants
                                    .map((p) => p.participant)
                                    .contains(p))
                                .map((m) => m.responses)
                                .fold<int>(0, (x, y) => x + y))),
                      ),
                      dicts: Map.fromEntries(
                        widget.meetings
                            .map((e) => e.participants)
                            .expand((element) => element)
                            .map((p) => MapEntry(p.participant, p.needed))
                            .where((p) => p.value != 0),
                      ).group(),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: min(width * 0.01, max(0, width - 400)),
                  right: min(width * 0.02, max(0, width - 400)),
                  bottom: max(height * 0.05, 20.0),
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.all(Radius.circular(32.0)),
                  boxShadow: const [
                    BoxShadow(offset: Offset(0, 1), blurRadius: 2.0),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(height: height * 0.02),
                    Text(
                      LangText.detailedPrepared.local,
                      style: UITexts.sectionSubheader,
                    ),
                    BarGraph(
                      responseCount: Map.fromEntries(
                        allParticipants.map((p) => MapEntry(
                            p,
                            widget.meetings
                                .where((m) => m.participants
                                    .map((p) => p.participant)
                                    .contains(p))
                                .map((m) => m.responses)
                                .fold<int>(0, (x, y) => x + y))),
                      ),
                      dicts: Map.fromEntries(
                        widget.meetings
                            .map((e) => e.participants)
                            .expand((element) => element)
                            .map((p) => MapEntry(p.participant, p.prepared))
                            .where((p) => p.value != 0),
                      ).group(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tagsBuilder(List<String> texts, double maxWidth) {
    if (texts.isEmpty) {
      return const SizedBox();
    }

    double width;
    final lineNums = <int>[];
    int sum = 0;
    int index = 0;

    while (sum < texts.length) {
      width = 0;
      lineNums.add(0);
      for (; index < texts.length; index++) {
        double curWidth = _getTextSize(texts[index]).width;

        if (width + curWidth + 48.0 > maxWidth) {
          break;
        }
        width += curWidth + 48.0;
        lineNums.last += 1;
        sum += 1;
      }

      if (lineNums.last == 0) {
        lineNums.last = 1;
        sum += 1;
      }
    }

    final rows = <Widget>[];
    int cur = 0;
    while (lineNums.isNotEmpty) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: texts
              .getRange(cur, cur + lineNums[0])
              .map((t) => _singleTagBuilder(t, maxWidth))
              .toList(),
        ),
      );
      cur += lineNums[0];
      lineNums.removeAt(0);
    }

    return Column(children: rows);
  }

  Widget _singleTagBuilder(String tag, double maxWidth) {
    return Container(
      width: min(_getTextSize(tag).width + 34.0, maxWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [BoxShadow(offset: Offset(0, 0.5), blurRadius: 1.0)],
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Text(tag, style: UITexts.mediumText, textAlign: TextAlign.center),
    );
  }

  Size _getTextSize(String text) => (TextPainter(
        text: TextSpan(text: text, style: UITexts.mediumText),
        textDirection: TextDirection.ltr,
      )..layout())
          .size;

  Widget foregroundBuilder(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ListView(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.04),
            child: Text(
              LangText.summary.local,
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
          padding: EdgeInsets.only(top: height * 0.04, bottom: height * 0.03),
          decoration: const BoxDecoration(
            color: Color(0xFFE6E6E6),
            borderRadius: BorderRadius.all(Radius.circular(48.0)),
            boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 2.0)],
          ),
          child: Column(
            children: [
              if (widget.meetings.length == 1)
                Text(
                  '${widget.meetings.first.title} '
                  '${TimeOfDay.fromDateTime(widget.meetings.first.startTime).format(context)} - '
                  '${TimeOfDay.fromDateTime(widget.meetings.first.endTime).format(context)} '
                  '${widget.meetings.first.startTime.day}/${widget.meetings.first.startTime.month}/${widget.meetings.first.startTime.year}',
                  style: UITexts.sectionHeader,
                ),
              SizedBox(height: height * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedButton(
                    primaryColour: Colors.black,
                    selectedColour: Colors.white,
                    backgroundColour: Colors.blue.shade100,
                    onPressedColour: Colors.blue,
                    useShadow: false,
                    width: 180.0,
                    height: null,
                    isSelected: _selectedIndex == 0,
                    onPressed: (_) {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: SizedBox(
                      height: FontSizes.mediumTextSize * 1.5,
                      child: Text(
                        LangText.overallSat.local,
                        style: UITexts.smallButtonText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  SizedButton(
                    primaryColour: Colors.black,
                    selectedColour: Colors.white,
                    backgroundColour: Colors.blue.shade100,
                    onPressedColour: Colors.blue,
                    useShadow: false,
                    width: 180.0,
                    height: null,
                    isSelected: _selectedIndex == 1,
                    onPressed: (_) {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: SizedBox(
                      height: FontSizes.mediumTextSize * 1.5,
                      child: Text(
                        LangText.participants.local,
                        style: UITexts.smallButtonText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4.0),
                  SizedButton(
                    primaryColour: Colors.black,
                    selectedColour: Colors.white,
                    backgroundColour: Colors.blue.shade100,
                    onPressedColour: Colors.blue,
                    useShadow: false,
                    width: 180.0,
                    height: null,
                    isSelected: _selectedIndex == 2,
                    onPressed: (_) {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    child: SizedBox(
                      height: FontSizes.mediumTextSize * 1.5,
                      child: Text(
                        LangText.feedback.local,
                        style: UITexts.smallButtonText,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 0.0, thickness: 5.0, color: Colors.blue),
              Padding(
                padding: EdgeInsets.only(top: height * 0.04),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [
                    pieChartBuilder(context),
                    barGraphBuilder(context),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        width: width * 0.7,
                        margin: EdgeInsets.only(
                          bottom: max(height * 0.05, 20.0),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(32.0),
                          ),
                          boxShadow: const [
                            BoxShadow(offset: Offset(0, 0.5), blurRadius: 1.0),
                          ],
                        ),
                        child: _tagsBuilder(
                          widget.meetings
                              .map((e) => e.feedback)
                              .expand((element) => element)
                              .toList(),
                          width * 0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
          const LogOutButton(),
          LanguageSwitcher(callback: () => setState(() => {})),
          Positioned(
            left: 64.0,
            top: 24.0,
            child: SizedButton(
              backgroundColour: const Color.fromRGBO(239, 198, 135, 1),
              primaryColour: Colors.black,
              onPressedColour: const Color.fromRGBO(239, 198, 135, 1),
              height: 48.0,
              width: 48.0,
              radius: BorderRadius.circular(24.0),
              onPressed: (_) => Navigator.of(context).pop(),
              child: const Icon(Icons.arrow_back, size: 32.0),
            ),
          ),
        ],
      ),
    );
  }
}

Map<String, double> binQualityReviews(List<Meeting> meetings) {
  List<double> qualities =
      meetings.map((e) => e.qualities).expand((element) => element).toList();
  List<double> sortedQualities = qualities.toList()..sort();
  int awful = sortedQualities.takeWhile((value) => value <= 0.2).length;
  int bad = sortedQualities
      .skipWhile((value) => value <= 0.2)
      .takeWhile((value) => value <= 0.4)
      .length;
  int ok = sortedQualities
      .skipWhile((value) => value <= 0.4)
      .takeWhile((value) => value <= 0.6)
      .length;
  int great = sortedQualities
      .skipWhile((value) => value <= 0.6)
      .takeWhile((value) => value <= 0.8)
      .length;
  int amazing = sortedQualities
      .skipWhile((value) => value <= 0.8)
      .takeWhile((value) => value <= 1.0)
      .length;

  return {
    LangText.amazing.local: amazing.toDouble(),
    LangText.great.local: great.toDouble(),
    LangText.ok.local: ok.toDouble(),
    LangText.bad2.local: bad.toDouble(),
    LangText.inadequate.local: awful.toDouble(),
  };
}

extension ParticipantMapExtension on Map<Participant, int> {
  Map<Participant, int> group() {
    Map map = {};
    forEach((participant, notNeeded) {
      if (map.containsKey(participant)) {
        int temp = map[participant];
        map[participant] = temp + notNeeded;
      } else {
        map[participant] = notNeeded;
      }
    });
    return map.map((key, value) => MapEntry(key as Participant, value as int));
  }
}
