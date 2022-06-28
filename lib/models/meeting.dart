import 'package:flutter/material.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/models/date_time_json.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/json_helpers.dart';

/// The model for meetings.
class Meeting {
  final String? meetingId;
  final String title;
  DateTime startTime;
  DateTime endTime;
  final String organiserId;
  final List<TaggedParticipant> participants;
  final Map<String, TaggedPresets> painPoints;
  final List<double> qualities;
  final int responses;
  final List<String> feedback;

  Meeting({
    this.meetingId,
    required this.title,
    required this.startTime,
    required this.organiserId,
    required this.endTime,
    required this.qualities,
    required this.responses,
    this.participants = const [],
    this.feedback = const [],
    this.painPoints = const {},
  });

  Participant? get organiser {
    for (final p in participants) {
      if (p.participant.id == organiserId) {
        return p.participant;
      }
    }
    return null;
  }

  static Meeting? fromJson(Map<String, dynamic> json) {
    try {
      return Meeting(
        feedback: JH.asList(
          json[Fields.feedbacks],
          listErrMsg: (t) => 'Field "feedback" should be a list, but is a $t',
          castErrMsg:
              'Field "feedback" should have an element type of "String"',
        ),
        title: json[Fields.title] ?? JH.toss('Field "title" is NULL'),
        meetingId: json[Fields.meetingId],
        startTime: DateTimeJson.fromJSON(json[Fields.startTime]) ??
            JH.toss('Field "startTime" is NULL'),
        endTime: DateTimeJson.fromJSON(json[Fields.endTime]) ??
            JH.toss('Field "endTime" is NULL'),
        qualities: JH.asList(
          json[Fields.qualities],
          listErrMsg: (t) => 'Field "qualities" should be a list, but is a $t',
          castErrMsg:
              'Field "qualities" should have an element type of "double"',
        ),
        responses:
            json[Fields.responses] ?? JH.toss('Field "responses" is NULL'),
        organiserId:
            json[Fields.organiserId] ?? JH.toss('Field "organiserId" is NULL'),
        participants: (json[Fields.participants] as List<dynamic>?)
                ?.map((e) => TaggedParticipant.fromJson(e)!)
                .toList() ??
            const [],
        painPoints: Map.fromEntries(
          (json[Fields.painPoints] as List<dynamic>?)?.map(
                (e) => MapEntry(
                  e['presetQ'][Fields.id],
                  TaggedPresets(
                    content: e['presetQ']['text'],
                    selectCount: e['selected'],
                  ),
                ),
              ) ??
              const [],
        ),
      );
    } catch (e) {
      debugPrint("Error on deserialising meeting: $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        Fields.feedbacks: feedback,
        Fields.title: title,
        Fields.startTime: startTime.toJSON(),
        Fields.endTime: endTime.toJSON(),
        Fields.organiserId: organiserId,
        Fields.qualities: qualities,
        Fields.responses: responses,
        Fields.painPoints: painPoints.entries
            .map(
              (e) => {
                'presetQ': {
                  Fields.id: e.key,
                  'text': e.value.content,
                },
                if (e.value.selectCount != null)
                  'selected': e.value.selectCount,
              },
            )
            .toList(),
        Fields.participants: participants.map((e) => e.toJson()).toList(),
        if (meetingId != null) Fields.meetingId: meetingId,
      };
}

/// The builder for [Meeting].

class MeetingBuilder with ChangeNotifier {
  String? _meetingId;
  late String title;
  late String organiserId;
  // final MeetingDateAndTime meetingDateAndTime = MeetingDateAndTime();
  final Set<Participant> participants = {};
  double? quality;
  final List<String> feedback = [];

  String? get meetingId => _meetingId;

  set meetingId(String? value) {
    _meetingId = value;
    notifyListeners();
  }

  /// Build a [Meeting].
  Meeting build() => Meeting(
        organiserId: organiserId,
        title: title,
        qualities: [],
        responses: 0,
        feedback: feedback,
        startTime: DateTime.fromMillisecondsSinceEpoch(0),
        endTime: DateTime.fromMillisecondsSinceEpoch(0),
        participants: participants
            .map(
              (p) => TaggedParticipant(
                participant: p,
                notNeeded: 0,
                notPrepared: 0,
                needed: 0,
                prepared: 0,
              ),
            )
            .toList(),
      );

  /// Notify the listeners.
  void notify() {
    notifyListeners();
  }
}

class TaggedPresets {
  final String content;
  final int? selectCount;

  const TaggedPresets({required this.content, required this.selectCount});
}

/// [Participant] with their corresponding votes by others.
class TaggedParticipant {
  final Participant participant;
  final int notNeeded;
  final int notPrepared;
  final int needed;
  final int prepared;

  const TaggedParticipant({
    required this.participant,
    required this.notNeeded,
    required this.notPrepared,
    required this.needed,
    required this.prepared,
  });

  static TaggedParticipant? fromJson(Map<String, dynamic> json) {
    try {
      return TaggedParticipant(
        participant: Participant.fromJson(json[Fields.participant]),
        notNeeded: json[Fields.notNeeded],
        notPrepared: json[Fields.notPrepared],
        needed: json[Fields.needed],
        prepared: json[Fields.prepared],
      );
    } catch (e) {
      debugPrint("Error on deserialising tagged participant: $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        Fields.participant: participant.toJson(),
        Fields.notNeeded: notNeeded,
        Fields.notPrepared: notPrepared,
        Fields.needed: needed,
        Fields.prepared: prepared,
      };
}
