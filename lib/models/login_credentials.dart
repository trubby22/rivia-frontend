import 'package:crypt/crypt.dart';

String salt = 'yNwYRfX9mxQ-An#8sUw_a7LQgPaRe+a4';

class LoginCredentials {
  final String loginHash;
  final String passwordHash;

  LoginCredentials({
    required String login,
    required String password,
  })  : loginHash = Crypt.sha256(login, salt: salt).toString(),
        passwordHash = Crypt.sha256(password, salt: salt).toString();
}