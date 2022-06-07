import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/api_endpoints.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/date_picker.dart';
import 'package:rivia/utilities/stateful_checkbox.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/time_picker.dart';

import 'package:http/http.dart' as http;

class CreateMeeting extends StatefulWidget {
  final List<Participant> allParticipants;

  CreateMeeting({
    Key? key,
    required this.allParticipants,
  }) : super(key: key);

  @override
  State<CreateMeeting> createState() => _CreateMeetingState();
}

class _CreateMeetingState extends State<CreateMeeting> {
  TextEditingController _nameController = TextEditingController();
  late List<bool> _selectedParticipants =
      List.generate(widget.allParticipants.length, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          ElevatedButton(onPressed: () {}, child: Icon(Icons.flag)),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (_) => MeetingDateAndTime(),
        child: Padding(
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
                                      children: List.generate(
                                          widget.allParticipants.length,
                                          (index) {
                                        return Row(
                                          children: [
                                            Checkbox(
                                              value:
                                                  _selectedParticipants[index],
                                              onChanged: (_) {
                                                setState(() {
                                                  _selectedParticipants[index] =
                                                      !_selectedParticipants[
                                                          index];
                                                });
                                              },
                                            ),
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
                            Expanded(child: Consumer<MeetingDateAndTime>(
                              builder: (context, meetingDateAndTime, child) {
                                return DatePicker(
                                  restorationId: 'meetingDate',
                                  meetingDateAndTime: meetingDateAndTime,
                                );
                              },
                            )),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Text('Start:')),
                            Expanded(child: Consumer<MeetingDateAndTime>(
                              builder: (context, meetingDateAndTime, child) {
                                return TimePicker(
                                  startEnd: StartEnd.start,
                                  meetingDateAndTime: meetingDateAndTime,
                                );
                              },
                            )),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(child: Text('Start:')),
                            Expanded(child: Consumer<MeetingDateAndTime>(
                              builder: (context, meetingDateAndTime, child) {
                                return TimePicker(
                                  startEnd: StartEnd.end,
                                  meetingDateAndTime: meetingDateAndTime,
                                );
                              },
                            )),
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
                      Consumer<MeetingDateAndTime>(
                          builder: (context, meetingDateAndTime, child) {
                        return ElevatedButton(
                            onPressed: () {
                              createMeeting(meetingDateAndTime);
                              Navigator.of(context).pop();
                            },
                            child: Text('Create meeting'));
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void createMeeting(MeetingDateAndTime meetingDateAndTime) {
    String meetingName = _nameController.value.text;
    List<Participant> participantList = [];
    widget.allParticipants.asMap().forEach((index, participant) {
      if (_selectedParticipants[index]) {
        participantList.add(participant);
      }
    });

    DateTime date = meetingDateAndTime.date ?? DateTime.now();
    TimeOfDay startTime = meetingDateAndTime.startTime ?? TimeOfDay.now();
    TimeOfDay endTime = meetingDateAndTime.endTime ?? TimeOfDay.now();

    DateTime startDate = DateTime(
        date.year, date.month, date.day, startTime.hour, startTime.minute);
    DateTime endDate =
        DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

    Meeting meeting =
        Meeting(title: meetingName, startTime: startDate, endTime: endDate);

    postNewMeetingOnBackend(meeting);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Meeting created: $meeting'),
    ));
  }

  void postNewMeetingOnBackend(Meeting meeting) {
    http.post(
      Uri.parse(apiGateway + postMeeting),
      body: meeting.toJson(),
    );
  }
}
