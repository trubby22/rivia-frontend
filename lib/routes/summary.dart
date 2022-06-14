import 'package:flutter/material.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartSummary extends StatefulWidget {
  const PieChartSummary({Key? key, required this.meeting}) : super(key: key);

  final Meeting meeting;

  @override
  State<PieChartSummary> createState() => _PieChartSummaryState();
}

class _PieChartSummaryState extends State<PieChartSummary> {
  Widget foregroundBuilder(BuildContext context) {
    Map<String, double> dataMap = binQualityReviews(widget.meeting);
    return PieChart(dataMap: dataMap);
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
