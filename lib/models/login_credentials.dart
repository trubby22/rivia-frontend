import 'package:crypt/crypt.dart';
import 'package:rivia/constants/fields.dart';

String salt = 'yNwYRfX9mxQ-An#8sUw_a7LQgPaRe+a4';

class LoginCredentials {
  final String loginHash;
  final String passwordHash;
  final String? firstName;
  final String? surname;

  LoginCredentials({
    required String login,
    required String password,
    this.firstName,
    this.surname,
  })  : loginHash = Crypt.sha256(login, salt: salt).toString(),
        passwordHash = Crypt.sha256(password, salt: salt).toString();

  LoginCredentials.fromJson(Map<String, dynamic> json)
      : loginHash = json[Fields.email],
        passwordHash = json[Fields.password],
        firstName = json[Fields.name],
        surname = json[Fields.surname];

  Map<String, dynamic> toJson() => {
        Fields.email: loginHash,
        Fields.password: passwordHash,
        Fields.name: firstName,
        Fields.surname: surname,
      };
}
