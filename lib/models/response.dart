import 'package:flutter/material.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/models/participant.dart';

/// The class for user responses.
class Response {
  final Participant participant;
  final double quality;
  final Map<String, String> painPoints;
  final List<Participant> notNeeded;
  final List<Participant> notPrepared;
  final String? feedback;

  Response({
    required this.participant,
    required this.quality,
    this.painPoints = const {},
    this.notNeeded = const [],
    this.notPrepared = const [],
    this.feedback,
  });

  Response.fromJson(Map<String, dynamic> json)
      : participant = Participant.fromJson(json[Fields.participant]),
        quality = json[Fields.quality],
        painPoints =
            (json[Fields.painPoints] as Map<String, dynamic>?)?.cast() ??
                const {},
        notNeeded = (json[Fields.notNeeded] as List<dynamic>?)
                ?.map((e) => Participant.fromJson(e))
                .toList() ??
            const [],
        notPrepared = (json[Fields.notPrepared] as List<dynamic>?)
                ?.map((e) => Participant.fromJson(e))
                .toList() ??
            const [],
        feedback = json[Fields.feedback];

  Map<String, dynamic> toJson() => {
        Fields.participant: participant.toJson(),
        Fields.quality: quality,
        Fields.painPoints: painPoints.map(
          (key, value) => MapEntry("$key", value),
        ),
        Fields.notNeeded: notNeeded.map((e) => e.toJson()).toList(),
        Fields.notPrepared: notPrepared.map((e) => e.toJson()).toList(),
        if (feedback != null) Fields.feedback: feedback,
      };
}

/// A builder for [Response].
class ResponseBuilder with ChangeNotifier {
  late Participant participant;
  double quality = 0.5;
  Map<String, String> painPoints = {};
  final List<Participant> notNeeded = [];
  final List<Participant> notPrepared = [];
  String? feedback;

  /// Build to [Response].
  Response build() => Response(
        participant: participant,
        quality: quality,
        painPoints: painPoints,
        notNeeded: notNeeded,
        notPrepared: notPrepared,
        feedback: feedback,
      );
}
