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
  final List<Participant> needed;
  final List<Participant> prepared;
  final String? feedback;

  Response({
    required this.participant,
    required this.quality,
    this.painPoints = const {},
    this.notNeeded = const [],
    this.notPrepared = const [],
    this.needed = const [],
    this.prepared = const [],
    this.feedback,
  });

  Response.fromJson(Map<String, dynamic> json)
      : participant = Participant.fromJson(json[Fields.participant]),
        quality = json[Fields.qualities],
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
        needed = (json[Fields.needed] as List<dynamic>?)
                ?.map((e) => Participant.fromJson(e))
                .toList() ??
            const [],
        prepared = (json[Fields.prepared] as List<dynamic>?)
                ?.map((e) => Participant.fromJson(e))
                .toList() ??
            const [],
        feedback = json[Fields.feedback];

  Map<String, dynamic> toJson() => {
        Fields.participant: participant.toJson(),
        Fields.qualities: quality,
        Fields.painPoints: painPoints,
        Fields.notNeeded: notNeeded.map((e) => e.toJson()).toList(),
        Fields.notPrepared: notPrepared.map((e) => e.toJson()).toList(),
        Fields.needed: needed.map((e) => e.toJson()).toList(),
        Fields.prepared: prepared.map((e) => e.toJson()).toList(),
        if (feedback != null) Fields.feedback: feedback,
      };
}

/// A builder for [Response].
class ResponseBuilder with ChangeNotifier {
  late Participant participant;
  double _quality = 0.5;
  Map<String, String> painPoints = {};
  final Set<Participant> notNeeded = {};
  final Set<Participant> notPrepared = {};
  final Set<Participant> needed = {};
  final Set<Participant> prepared = {};
  String? feedback;

  double get quality => _quality;
  set quality(double value) {
    _quality = value;
    notifyListeners();
  }

  /// Build to [Response].
  Response build() => Response(
        participant: participant,
        quality: quality,
        painPoints: painPoints,
        notNeeded: notNeeded.toList(),
        notPrepared: notPrepared.toList(),
        needed: needed.toList(),
        prepared: prepared.toList(),
        feedback: feedback?.trim(),
      );

  /// Notify the listeners.
  void notify() {
    notifyListeners();
  }
}
