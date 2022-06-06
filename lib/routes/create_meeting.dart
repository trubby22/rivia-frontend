import 'package:flutter/material.dart';
import 'package:rivia/helper_widgets/date_picker.dart';
import 'package:rivia/helper_widgets/stateful_checkbox.dart';
import 'package:rivia/helper_widgets/time_picker.dart';

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
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                filled: true,
                                labelText: 'Meeting name',
                              ),
                              controller: _nameController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Text('Participants:')),
                          Expanded(
                            child: Column(
                              children: [
                                ElevatedButton(
                                    onPressed: () {},
                                    child: Text('select all')),
                                SizedBox(height: 8.0),
                                Expanded(
                                  child: ListView(
                                    children: List.generate(10, (index) {
                                      return Row(
                                        children: [
                                          StatefulCheckbox(),
                                          Text('Participant $index'),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                              ],
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Create meeting')),
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
