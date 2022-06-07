import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';

/// A [Widget] showing the snapshot of a [Meeting] in the calendar.
class MeetingEntry extends StatelessWidget {
  const MeetingEntry({Key? key, required this.meeting}) : super(key: key);

  final Meeting meeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500.0,
      height: 150.0,
      color: Colors.amber.shade100,
      child: TextButton(
        onPressed: () => Navigator.pushNamed(
          context,
          RouteNames.review,
          arguments: meeting,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.black,
                  size: 86.0,
                ),
                Column(
                  children: [
                    Text(
                      meeting.title,
                      style: UITexts.sectionSubheader,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${LangText.date.local}: ${meeting.startTime.day}/${meeting.startTime.month}/${meeting.startTime.year}',
                      style: UITexts.mediumText,
                    ),
                    Text(
                      '${LangText.startTime.local}: ${TimeOfDay.fromDateTime(meeting.startTime).format(context)}',
                      style: UITexts.mediumText,
                    ),
                    Text(
                      '${LangText.endTime.local}: ${TimeOfDay.fromDateTime(meeting.endTime).format(context)}',
                      style: UITexts.mediumText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
