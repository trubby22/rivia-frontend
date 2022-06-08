import 'dart:convert';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/api_endpoints.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/date_picker.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/sized_button.dart';
import 'package:rivia/utilities/time_picker.dart';

import 'package:http/http.dart' as http;

class CreateMeeting extends StatefulWidget {
  final List<Participant> allParticipants;

  const CreateMeeting({
    Key? key,
    required this.allParticipants,
  }) : super(key: key);

  @override
  State<CreateMeeting> createState() => _CreateMeetingState();
}

class _CreateMeetingState extends State<CreateMeeting> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getLang(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LangText.createMeeting.local),
        actions: [
          Consumer<User>(
            builder: (context, user, child) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteNames.login);
                  user.uuid = null;
                },
                child: Icon(Icons.logout),
              );
            },
          ),
          // ignore: prefer_const_constructors
          LanguageSwitcher(),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (_) => MeetingBuilder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    filled: true,
                    labelText: LangText.meetingName.local,
                  ),
                  controller: _nameController,
                ),
              ),
              Text(
                LangText.participants.local,
                style: UITexts.sectionSubheader,
              ),
              Selector<MeetingBuilder, Tuple2<int, Set<Participant>>>(
                selector: (_, data) =>
                    Tuple2(data.participants.length, data.participants),
                builder: (context, data, _) => SizedButton(
                  child: Text(
                    LangText.all.local,
                    style: UITexts.mediumButtonText,
                  ),
                  isSelected: data.value1 == widget.allParticipants.length,
                  onPressed: (isSelected) {
                    if (isSelected) {
                      data.value2.clear();
                    } else {
                      data.value2.addAll(widget.allParticipants);
                    }
                    context.read<MeetingBuilder>().notify();
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              Expanded(
                child: ListView(
                  children: List.generate(
                    widget.allParticipants.length,
                    (index) {
                      return Row(
                        children: [
                          Selector<MeetingBuilder,
                              Tuple2<int, Set<Participant>>>(
                            selector: (_, data) => Tuple2(
                                data.participants.length, data.participants),
                            builder: (context, data, _) => Checkbox(
                              value: data.value2.contains(
                                widget.allParticipants[index],
                              ),
                              onChanged: (isSelected) {
                                if (isSelected ?? false) {
                                  data.value2
                                      .add(widget.allParticipants[index]);
                                } else {
                                  data.value2.remove(
                                    widget.allParticipants[index],
                                  );
                                }
                                context.read<MeetingBuilder>().notify();
                              },
                            ),
                          ),
                          Text(widget.allParticipants[index].fullName),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Text(LangText.date.local, style: UITexts.sectionSubheader),
                  Selector<MeetingBuilder, MeetingDateAndTime>(
                    selector: (_, data) => data.meetingDateAndTime,
                    builder: (context, data, _) => DatePicker(
                      restorationId: 'meetingDate',
                      meetingDateAndTime: data,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Text(
                    LangText.startTime.local,
                    style: UITexts.sectionSubheader,
                  ),
                  Selector<MeetingBuilder, MeetingDateAndTime>(
                    selector: (_, data) => data.meetingDateAndTime,
                    builder: (context, data, _) => TimePicker(
                      startEnd: StartEnd.start,
                      meetingDateAndTime: data,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Row(
                children: [
                  Text(
                    LangText.endTime.local,
                    style: UITexts.sectionSubheader,
                  ),
                  Selector<MeetingBuilder, MeetingDateAndTime>(
                    selector: (_, data) => data.meetingDateAndTime,
                    builder: (context, data, _) => TimePicker(
                      startEnd: StartEnd.end,
                      meetingDateAndTime: data,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Consumer<MeetingBuilder>(
                      builder: (context, meetingDateAndTime, child) {
                        return ElevatedButton(
                          onPressed: () async {
                            await createMeeting(meetingDateAndTime, context);
                            Navigator.of(context).pop();
                          },
                          child: Text(LangText.createMeeting.local),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createMeeting(
    MeetingBuilder meetingBuilder,
    BuildContext context,
  ) async {
    context.read<MeetingBuilder>().title = _nameController.text;
    Meeting meeting = context.read<MeetingBuilder>().build();

    bool result = await postNewMeetingOnBackend(meeting);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result
          ? 'Meeting created: ${meeting.toJson()}'
          : 'Create meeting failed: ${meeting.toJson()}'),
    ));
  }

  Future<bool> postNewMeetingOnBackend(Meeting meeting) async {
    try {
      final response = await http.post(
        Uri.parse(apiGateway + postMeeting),
        body: json.encode(meeting.toJson()),
      );
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
