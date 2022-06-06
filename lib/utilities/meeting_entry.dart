import 'package:flutter/material.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';

/// A [Widget] showing the snapshot of a [Meeting] in the calendar.
class MeetingEntry extends StatelessWidget {
  const MeetingEntry({Key? key, required this.meeting}) : super(key: key);

  final Meeting meeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.0,
      height: 150.0,
      color: Colors.purple,
      child: TextButton(
        onPressed: () => Navigator.pushNamed(
          context,
          '/review',
          arguments: meeting,
        ),
        child: Center(
          child: Text(meeting.title, style: UITexts.sectionSubheader),
        ),
      ),
    );
  }
}
