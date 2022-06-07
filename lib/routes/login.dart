import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/api_endpoints.dart';
import 'package:rivia/models/login_credentials.dart';

import 'package:http/http.dart' as http;
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  bool _signup = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          actions: [
            ElevatedButton(onPressed: () {}, child: Icon(Icons.flag)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                if (_signup) ...[
                  TextField(
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'First Name',
                    ),
                    controller: _firstNameController,
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Surname',
                    ),
                    controller: _surnameController,
                  ),
                  const SizedBox(height: 12.0),
                ],
                TextField(
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Email',
                  ),
                  controller: _loginController,
                ),
                const SizedBox(height: 12.0),
                TextField(
                  decoration: const InputDecoration(
                    filled: true,
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 12.0),
                Consumer<User>(
                  builder: (context, user, child) {
                    return ElevatedButton(
                        onPressed: () {
                          login(context, user);
                          Navigator.of(context).pushNamed('/dashboard_assigned');
                        },
                        child: Text(_signup ? 'Sign Up' : 'Log In'));
                  },
                ),
                const SizedBox(height: 12.0),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _signup = !_signup;
                      });
                    },
                    child: Text(
                        'Click here to ${_signup ? 'Log In' : 'Sign Up'} instead')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void login(BuildContext context, User user) {
    String login = _loginController.value.text;
    String password = _passwordController.value.text;
    String firstName = _firstNameController.value.text;
    String surname = _surnameController.value.text;
    _loginController.clear();
    _passwordController.clear();
    _firstNameController.clear();
    _surnameController.clear();

    LoginCredentials loginCredentials = LoginCredentials(
      login: login,
      password: password,
      firstName: _signup ? firstName : null,
      surname: _signup ? surname : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Login data sent successfully: ${loginCredentials.login}, '
          '${loginCredentials.passwordHash}, ${loginCredentials.login == loginCredentials.passwordHash}'),
    ));

    postLoginCredentialsToBackend(loginCredentials, user);
  }
}
