import 'package:clicker/constants/fields.dart';
import 'package:clicker/models/participant.dart';

/// The model for meetings.
class Meeting {
  final String title;
  final DateTime startTime;
  final DateTime endTime;
  final List<Participant> participants;

  Meeting({
    required this.title,
    required this.startTime,
    required this.endTime,
    this.participants = const [],
  });

  Meeting.fromJson(Map<String, dynamic> json)
      : title = json[Fields.title],
        startTime = json[Fields.startTime],
        endTime = json[Fields.endTime],
        participants =
            (json[Fields.participantId] as List<Map<String, dynamic>>?)
                    ?.map((e) {
                  print(e);
                  return Participant.fromJson(e);
                }).toList() ??
                const [];

  Map<String, dynamic> toJson() => {
        Fields.title: title,
        Fields.startTime: startTime,
        Fields.endTime: endTime,
        Fields.participants: participants.map((e) => e.toJson()),
      };
}
