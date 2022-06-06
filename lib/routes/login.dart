import 'package:flutter/material.dart';

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
              ),
              const SizedBox(height: 12.0),
              TextField(
                decoration: const InputDecoration(
                  filled: true,
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 12.0),
              ElevatedButton(onPressed: () {
                Navigator.of(context).pushNamed('/dashboard_assigned');
              }, child: Text('Log In / Sign Up')),
            ],
          ),
        ),
      ),
    );
  }
}
