// Most of the code comes from the template

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page Edited From CI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _backendString = 'initial string';

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  // New function
  Future<http.Response> fetchNumber() {
    return http.get(Uri.parse('https://28p2bz73y5.execute-api.eu-west-2'
        '.amazonaws.com/my-function-3'));
  }

  // New function
  Future<http.Response> incrementNumber() {
    return http.put(Uri.parse('https://28p2bz73y5.execute-api.eu-west-2'
        '.amazonaws.com/my-function-4'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            // Important part starts here
            ElevatedButton(
                onPressed: () async {
                  final response = await fetchNumber();
                  setState(() {
                    _backendString = response.body;
                  });
                },
                child: Text('fetch data')),
            ElevatedButton(
                onPressed: () async {
                  await incrementNumber();

                  final response = await fetchNumber();
                  setState(() {
                    _backendString = response.body;
                  });
                },
                child: Text('increment')),
            Text(_backendString),
          //  And ends here
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
