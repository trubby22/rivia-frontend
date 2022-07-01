import 'dart:convert';
import 'dart:math';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/routes/redirect.dart';
import 'package:rivia/utilities/bar_graph.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:rivia/utilities/log_out_button.dart';
import 'package:rivia/utilities/sized_button.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MeetingSummary extends StatefulWidget {
  const MeetingSummary({
    Key? key,
    required this.meetings,
    this.pop = true,
  }) : super(key: key);

  final List<Meeting> meetings;
  final bool pop;

  @override
  State<MeetingSummary> createState() => _MeetingSummaryState();
}

class _MeetingSummaryState extends State<MeetingSummary> {
  int _selectedIndex = 0;

  WebSocketChannel? _webSocket;

  Widget pieChartBuilder(BuildContext context) {
    return PieChart(
      chartLegendSpacing: 128.0,
      dataMap: binQualityReviews(widget.meetings),
      legendOptions: const LegendOptions(
        legendTextStyle: UITexts.sectionSubheader,
      ),
      chartRadius: MediaQuery.of(context).size.width / 3.5,
      initialAngleInDegree: 270,
      chartValuesOptions: const ChartValuesOptions(
        showChartValuesInPercentage: true,
        chartValueStyle: UITexts.sectionSubheader,
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
      // print(m.toJson());
      allParticipants.addAll(m.participants.map((p) => p.participant));
    }

    // Map.fromEntries(
    //   allParticipants.map(
    //     (p) => MapEntry(
    //         p,
    //         2 *
    //             widget.meetings
    //                 .where((m) =>
    //                     m.participants.map((p) => p.participant).contains(p))
    //                 .map(
    //                   (m) => m.responses,
    //                 )
    //                 .fold<int>(0, (x, r) => x + r)),
    //   ),
    // ).forEach((key, value) {
    //   print('p: ${key.toJson()}, i: $value');
    // });

    return Row(
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
                  LangText.detailedNeededRate.local,
                  style: UITexts.sectionSubheader,
                ),
                BarGraph(
                  key: ValueKey(
                    widget.meetings
                        .map((e) => e.responses)
                        .fold<int>(0, (a, b) => a + b),
                  ),
                  responseCount: Map.fromEntries(
                    allParticipants.map(
                      (p) => MapEntry(
                          p,
                          2 *
                              widget.meetings
                                  .where((m) => m.participants
                                      .map((p) => p.participant)
                                      .contains(p))
                                  .map(
                                    (m) => m.responses,
                                  )
                                  .fold<int>(0, (x, r) => x + r)),
                    ),
                  ),
                  dicts: Map.fromEntries(
                    allParticipants.map(
                      (p) => MapEntry(
                        p,
                        widget.meetings
                            .where((m) => m.participants
                                .map((p) => p.participant)
                                .contains(p))
                            .map(
                              (m) => Tuple2(
                                m.responses,
                                m.participants
                                    .firstWhere((pp) => pp.participant == p),
                              ),
                            )
                            .fold<int>(
                              0,
                              (x, rp) =>
                                  x +
                                  rp.value1 +
                                  rp.value2.needed -
                                  rp.value2.notNeeded,
                            ),
                      ),
                    ),
                  ),
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
                  LangText.detailedPreparedRate.local,
                  style: UITexts.sectionSubheader,
                ),
                BarGraph(
                  key: ValueKey(
                    widget.meetings
                        .map((e) => e.responses)
                        .fold<int>(0, (a, b) => a + b),
                  ),
                  responseCount: Map.fromEntries(
                    allParticipants.map(
                      (p) => MapEntry(
                        p,
                        2 *
                            widget.meetings
                                .where((m) => m.participants
                                    .map((p) => p.participant)
                                    .contains(p))
                                .map(
                                  (m) => m.responses,
                                )
                                .fold<int>(0, (x, r) => x + r),
                      ),
                    ),
                  ),
                  dicts: Map.fromEntries(
                    allParticipants.map(
                      (p) => MapEntry(
                        p,
                        widget.meetings
                            .where((m) => m.participants
                                .map((p) => p.participant)
                                .contains(p))
                            .map(
                              (m) => Tuple2(
                                m.responses,
                                m.participants
                                    .firstWhere((pp) => pp.participant == p),
                              ),
                            )
                            .fold<int>(
                              0,
                              (x, rp) =>
                                  x +
                                  rp.value1 +
                                  rp.value2.prepared -
                                  rp.value2.notPrepared,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget presetBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final painPoints = <String, int>{};

    for (final ps in widget.meetings.map((m) => m.painPoints.values)) {
      for (final p in ps) {
        painPoints[p.content] =
            (painPoints[p.content] ?? 0) + (p.selectCount ?? 0);
      }
    }

    final sortedPainPoints = painPoints.entries.toList()
      ..sort(
        (x, y) => y.value.compareTo(x.value),
      );

    return Center(
      child: Column(
        children: [
          Text(LangText.presetNum.local, style: UITexts.sectionSubheader),
          SizedBox(height: height * 0.02),
          Container(
            margin: const EdgeInsets.only(top: 12.0),
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: const [
                BoxShadow(offset: Offset(0, 0.5), blurRadius: 1.0),
              ],
            ),
            width: width * 0.5,
            child: Column(
              children: List.generate(
                sortedPainPoints.length,
                (ix) => Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        width: width * 0.4,
                        child: Text(
                          sortedPainPoints[ix].key,
                          style: UITexts.bigText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: width * 0.03),
                      Container(
                        width: FontSizes.bigTextSize + 20.0,
                        margin: const EdgeInsets.symmetric(vertical: 12.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(239, 198, 135, 1),
                          borderRadius: BorderRadius.circular(
                            FontSizes.bigTextSize + 10.0,
                          ),
                        ),
                        child: Text(
                          '${sortedPainPoints[ix].value}',
                          style: UITexts.bigText,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget feedbackBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Center(
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
                  '${widget.meetings.first.startTime.day}.${widget.meetings.first.startTime.month}.${widget.meetings.first.startTime.year}',
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
                    width: 240.0,
                    height: null,
                    isSelected: _selectedIndex == 0,
                    onPressed: (_) {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      height: FontSizes.bigTextSize * 1.75,
                      child: Text(
                        LangText.overallSat.local,
                        style: UITexts.mediumButtonText,
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
                    width: 240.0,
                    height: null,
                    isSelected: _selectedIndex == 1,
                    onPressed: (_) {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      height: FontSizes.bigTextSize * 1.75,
                      child: Text(
                        LangText.participants.local,
                        style: UITexts.mediumButtonText,
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
                    width: 240.0,
                    height: null,
                    isSelected: _selectedIndex == 2,
                    onPressed: (_) {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      height: FontSizes.bigTextSize * 1.75,
                      child: Text(
                        LangText.preset.local,
                        style: UITexts.mediumButtonText,
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
                    width: 240.0,
                    height: null,
                    isSelected: _selectedIndex == 3,
                    onPressed: (_) {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 5.0),
                      height: FontSizes.bigTextSize * 1.75,
                      child: Text(
                        LangText.feedback.local,
                        style: UITexts.mediumButtonText,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 0.0, thickness: 5.0, color: Colors.blue),
              Padding(
                padding: EdgeInsets.only(top: height * 0.04),
                child: StreamBuilder(
                  stream: _webSocket?.stream,
                  builder: (context, snapshot) {
                    if (snapshot.data != null) {
                      dynamic content = json.decode(snapshot.data!.toString());
                      // content = content[Fields.jsonData];
                      if (content?[Fields.meeting] != null) {
                        content[Fields.meeting][Fields.meetingId] =
                            content[Fields.id];
                        content = content[Fields.meeting];
                        final newMeeting = Meeting.fromJson(content);

                        widget.meetings.removeWhere(
                          (m) => m.meetingId == newMeeting?.meetingId,
                        );
                        if (newMeeting != null) {
                          widget.meetings.add(newMeeting);
                        }
                      }
                    }
                    return IndexedStack(
                      index: _selectedIndex,
                      children: [
                        pieChartBuilder(context),
                        barGraphBuilder(context),
                        presetBuilder(context),
                        feedbackBuilder(context),
                      ],
                    );
                  },
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
              onPressed: (_) {
                widget.pop
                    ? Navigator.of(context).pop()
                    : dashboard(context, null);
              },
              child: const Icon(Icons.arrow_back, size: 32.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _webSocket = getWebSocket();
  }

  @override
  void dispose() {
    disposeWebSocket(_webSocket);
    super.dispose();
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
