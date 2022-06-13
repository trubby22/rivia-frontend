import 'package:flutter/material.dart';
import 'package:rivia/models/meeting.dart';

class Analytics extends StatefulWidget {
  const Analytics({Key? key, required this.meetings}) : super(key: key);

  final List<Meeting> meetings;

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/general_bg.png',
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.fill,
        ),
        // foregroundBuilder(context),
      ],
    );
  }
}
