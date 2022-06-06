import 'package:flutter/material.dart';
import 'package:rivia/helper_widgets/date_picker.dart';
import 'package:rivia/helper_widgets/time_picker.dart';

class CreateMeeting extends StatelessWidget {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _startController = TextEditingController();
  TextEditingController _endController = TextEditingController();

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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.topCenter,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Text('Meeting name:')),
                          Expanded(
                              child: TextField(controller: _nameController)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Text('Participants:')),
                          Expanded(
                            child: ListView(
                              children: List.generate(10, (index) {
                                return Row(
                                  children: [
                                    Checkbox(value: false, onChanged: (_) {}),
                                    Text('Participant $index'),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Text('Date:')),
                          Expanded(
                              child: DatePicker(restorationId: 'meetingDate')),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Text('Start:')),
                          Expanded(child: TimePicker()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Text('End:')),
                          Expanded(child: TimePicker()),
                        ],
                      ),
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
      ),
    );
  }
}
