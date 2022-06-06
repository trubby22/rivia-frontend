import 'package:flutter/material.dart';

import '../models/meeting.dart';
import '../models/participant.dart';

List<String> painPoints = [
  'meeting overran',
  'meeting too short',
  'I spoke too little and listened too long',
  'too many people invited',
];

class Review extends StatelessWidget {
  final int participants_num = 6;
  final TextEditingController controller = TextEditingController();
  final Meeting meeting;

  Review({
    Key? key,
    required this.meeting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meeting.title),
        actions: [
          ElevatedButton(onPressed: () {}, child: Icon(Icons.flag)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: Column()),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: List.generate(
                        meeting.participants.length,
                        (index) {
                          Participant participant = meeting.participants[index];

                          return Row(
                            children: [
                              Card(
                                  child: Checkbox(
                                      value: false, onChanged: (_) {})),
                              Card(
                                  child: Checkbox(
                                      value: false, onChanged: (_) {})),
                              Card(child: Text(participant.fullName)),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      scrollDirection: Axis.horizontal,
                      children: List.generate(painPoints.length, (index) {
                        return GestureDetector(
                          child: Card(
                            child: Text(painPoints[index]),
                          ),
                          onTap: () {},
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(onPressed: () {}, child: Text('Save all')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
