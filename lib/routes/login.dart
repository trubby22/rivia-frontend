import 'package:flutter/material.dart';
import 'package:rivia/models/login_credentials.dart';

class Login extends StatelessWidget {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ElevatedButton(
                  onPressed: () {
                    login(context);
                    Navigator.of(context).pushNamed('/dashboard_assigned');
                  },
                  child: Text('Log In / Sign Up')),
            ],
          ),
        ),
      ),
    );
  }

  void login(BuildContext context) {
    String login = _loginController.value.text;
    String password = _passwordController.value.text;

    LoginCredentials loginCredentials =
        LoginCredentials(login: login, password: password);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          'Login data sent successfully: ${loginCredentials.loginHash}, '
          '${loginCredentials.passwordHash}, ${loginCredentials.loginHash == loginCredentials.passwordHash}'),
    ));
  }

  void postLoginCredentialsToBackend(LoginCredentials loginCredentials) {
    //  TODO()
  }
}
