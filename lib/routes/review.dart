import 'package:flutter/material.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/helper_widgets/sized_button.dart';

import 'package:rivia/models/meeting.dart';

List<String> painPoints = [
  'meeting overran',
  'meeting too short',
  'I spoke too little and listened too long',
  'too many people invited',
];

class Review extends StatelessWidget {
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: Column()),
            Expanded(
              flex: 3,
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120.0,
                            height: 40.0,
                            child: Center(
                              child: Text(
                                'Not Needed',
                                style: UITexts.mediumText,
                              ),
                            ),
                          ),
                          const SizedButton(
                            child: Text("ALL"),
                          ),
                          ...List.generate(
                            meeting.participants.length,
                            (_) => const SizedButton(
                              child: Text("N"),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 120.0,
                            height: 40.0,
                            child: Center(
                              child: Text(
                                'Not Prepared',
                                style: UITexts.mediumText,
                              ),
                            ),
                          ),
                          const SizedButton(
                            child: Text("ALL"),
                          ),
                          ...List.generate(
                            meeting.participants.length,
                            (_) => const SizedButton(
                              child: Text("P"),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40.0,
                              child: Center(
                                child: Text(
                                  'participant',
                                  style: UITexts.sectionSubheader,
                                ),
                              ),
                            ),
                            const SizedBox(height: 64.0),
                            ...List.generate(
                              meeting.participants.length,
                              (index) => SizedBox(
                                height: 64.0,
                                child: Center(
                                  child: Text(
                                    meeting.participants[index].fullName,
                                    style: UITexts.mediumText,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 500.0,
                    child: GridView.count(
                      crossAxisCount: 2,
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        painPoints.length,
                        (index) {
                          return GestureDetector(
                            child: Card(
                              child: Text(painPoints[index]),
                            ),
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Additional comments',
                    ),
                    controller: controller,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Submit review')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
