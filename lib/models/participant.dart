import 'package:rivia/constants/fields.dart';

/// The model for meeting participants.
class Participant {
  final String name;
  final String surname;
  final String email;
  final String? id;

  Participant({
    required this.name,
    required this.surname,
    required this.email,
    this.id,
  });

  Participant.fromJson(Map<String, dynamic> json)
      : name = json[Fields.name],
        surname = json[Fields.surname],
        email = json[Fields.email],
        id = json[Fields.participantId];

  Map<String, dynamic> toJson() => {
        Fields.name: name,
        Fields.surname: surname,
        Fields.email: email,
        Fields.participantId: id,
      };
}
