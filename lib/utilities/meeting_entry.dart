import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/toast.dart';

/// A [Widget] showing the snapshot of a [Meeting] in the calendar.
class MeetingEntry extends StatelessWidget {
  const MeetingEntry({Key? key, required this.meeting}) : super(key: key);

  final Meeting meeting;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150.0,
      color: Colors.amber.shade100,
      child: TextButton(
        onPressed: () async {
          if (meeting.meetingId == null) {
            debugPrint("Bad meeting without ID!");
            return;
          }

          final meetingContent = await getMeetingContent(meeting.meetingId!);
          if (meetingContent != null) {
            Navigator.pushNamed(
              context,
              RouteNames.review,
              arguments: meetingContent,
            );
          } else {
            showToast(
              context: context,
              text:
                  'Invalid meeting ${meeting.meetingId}! Please report this bug to the developers',
            );
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) => Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.black,
                      size: min(constraints.maxWidth, constraints.maxHeight),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        meeting.title,
                        style: UITexts.sectionSubheader,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${LangText.date.local}: ${meeting.startTime.day}.${meeting.startTime.month}.${meeting.startTime.year}',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
