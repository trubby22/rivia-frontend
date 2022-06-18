import 'package:rivia/constants/fields.dart';

/// The model for meeting participants.
class Participant {
  final String name;
  final String surname;
  final String? email;
  final String? id;

  Participant({
    required this.name,
    required this.surname,
    this.email,
    this.id,
  });

  @override
  operator ==(Object other) {
    if (other.runtimeType != Participant) {
      return false;
    }

    return (other as Participant).fullName == fullName;
  }

  get fullName => name + " " + surname;

  Participant.fromJson(Map<String, dynamic> json)
      : name = json[Fields.name],
        surname = json[Fields.surname],
        email = json[Fields.email],
        id = json[Fields.id];

  Map<String, dynamic> toJson() => {
        Fields.name: name,
        Fields.surname: surname,
        if (email != null) Fields.email: email,
        Fields.id: id,
      };

  @override
  int get hashCode => fullName.hashCode;
}
