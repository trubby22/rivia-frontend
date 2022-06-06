import 'package:flutter/material.dart';

class CreateMeeting extends StatelessWidget {
  TextEditingController _nameController = TextEditingController();

  CreateMeeting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          ElevatedButton(onPressed: () {}, child: Icon(Icons.flag)),
        ],
      ),
      body: Container(
        alignment: Alignment.topCenter,
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Meeting name:'),
                      TextField(controller: _nameController),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Participants:'),
                      ListView(
                        children: List.generate(10, (index) {
                          return Row(
                            children: [
                              Checkbox(value: false, onChanged: (_) {}),
                              Text('Participant $index'),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Start:'),
                      TextField(),
                    ],
                  ),
                  Row(
                    children: [
                      Text('End:'),
                      TextField(),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      onPressed: () {}, child: Text('Create meeting')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
