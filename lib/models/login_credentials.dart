import 'package:crypt/crypt.dart';
import 'package:rivia/constants/fields.dart';

String salt = 'yNwYRfX9mxQ-An#8sUw_a7LQgPaRe+a4';

class LoginCredentials {
  final String loginHash;
  final String passwordHash;

  LoginCredentials({
    required String login,
    required String password,
  })  : loginHash = Crypt.sha256(login, salt: salt).toString(),
        passwordHash = Crypt.sha256(password, salt: salt).toString();

  LoginCredentials.fromJson(Map<String, dynamic> json)
      : loginHash = json[Fields.email],
        passwordHash = json[Fields.password];

  Map<String, dynamic> toJson() => {
        Fields.email: loginHash,
        Fields.password: passwordHash,
      };
}
