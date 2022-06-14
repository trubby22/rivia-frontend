import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/bar_graph.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:rivia/utilities/sized_button.dart';

class MeetingSummary extends StatefulWidget {
  const MeetingSummary({Key? key, required this.meeting}) : super(key: key);

  final Meeting meeting;

  @override
  State<MeetingSummary> createState() => _MeetingSummaryState();
}

class _MeetingSummaryState extends State<MeetingSummary> {
  int _selectedIndex = 0;

  Widget pieChartBuilder(BuildContext context) {
    return PieChart(
      dataMap: binQualityReviews(widget.meeting),
      chartRadius: MediaQuery.of(context).size.width / 4,
      chartValuesOptions: const ChartValuesOptions(
        showChartValuesInPercentage: true,
        decimalPlaces: 0,
      ),
    );
  }

  Widget barGraphBuilder(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

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
                  LangText.detailedNotNeeded.local,
                  style: UITexts.sectionSubheader,
                ),
                BarGraph(
                  dicts: Map.fromEntries(
                    widget.meeting.participants
                        .map((p) => MapEntry(p.participant, p.notNeeded))
                        .where((p) => p.value != 0),
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
                  LangText.detailedNotPrepared.local,
                  style: UITexts.sectionSubheader,
                ),
                BarGraph(
                  dicts: Map.fromEntries(
                    widget.meeting.participants
                        .map((p) => MapEntry(p.participant, p.notPrepared))
                        .where((p) => p.value != 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget foregroundBuilder(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final List<String> feedback = widget.meeting.feedback;

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
          padding: EdgeInsets.only(top: height * 0.12, bottom: height * 0.03),
          decoration: const BoxDecoration(
            color: Color(0xFFE6E6E6),
            borderRadius: BorderRadius.all(Radius.circular(48.0)),
            boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 2.0)],
          ),
          child: Column(
            children: [
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
                        'Overall Satisfaction',
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
                        'Participants',
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
                      child: Text('Feedback', style: UITexts.smallButtonText),
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
                        // color: Colors.lightBlue,
                        decoration: const BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.all(Radius.circular(48.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(feedback.length, (index) {
                              return Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(feedback[index]),
                                ),
                              );
                            }),
                          ),
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
          LanguageSwitcher(callback: () => setState(() => {})),
        ],
      ),
    );
  }
}

Map<String, double> binQualityReviews(Meeting meeting) {
  List<double> qualities = [meeting.quality];
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
    'Awful': awful.toDouble(),
    'Bad': bad.toDouble(),
    'Ok': ok.toDouble(),
    'Great': great.toDouble(),
    'Amazing': amazing.toDouble(),
  };
}
