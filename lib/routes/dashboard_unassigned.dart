import 'package:flutter/material.dart';

class DashboardUnassigned extends StatelessWidget {
  const DashboardUnassigned({Key? key}) : super(key: key);

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
        child: Container(
          alignment: Alignment.topCenter,
          child: Column(
            children: [
              Text('You are currently not a part of any organisation\nAsk '
                  'your supervisor to add you to an organisation'),
            ],
          ),
        ),
      ),
    );
  }
}
