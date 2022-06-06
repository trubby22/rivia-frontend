import 'package:flutter/material.dart';

class DashboardAssigned extends StatelessWidget {
  const DashboardAssigned({Key? key}) : super(key: key);

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
        child: Row(
          children: [
            Spacer(),
            Expanded(
              child: Column(
                children: [
                  Text('Meetings'),
                  Column(
                      children: List.generate(
                          5, (index) => Card(child: Text('$index')))),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {}, child: Text('Create new meeting')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
