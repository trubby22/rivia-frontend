import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/date_picker.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/sized_button.dart';
import 'package:rivia/utilities/time_picker.dart';
import 'package:rivia/utilities/toast.dart';

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
    getSharedPref(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(LangText.createMeeting.local),
        actions: [
          Consumer<AuthToken>(
            builder: (context, user, child) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteNames.login);
                  user.reset();
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
          padding: EdgeInsets.symmetric(
            vertical: 24.0,
            horizontal: MediaQuery.of(context).size.width * 0.3,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  labelText: LangText.meetingName.local,
                ),
                controller: _nameController,
              ),
              const SizedBox(height: 12.0),
              Text(
                LangText.participants.local,
                style: UITexts.sectionSubheader,
              ),
              const SizedBox(height: 12.0),
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
              Center(
                child: Consumer<MeetingBuilder>(
                  builder: (context, meetingDateAndTime, child) {
                    return SizedButton(
                      width: null,
                      height: null,
                      isSelected: true,
                      padding: const EdgeInsets.all(16.0),
                      onPressed: (_) async {
                        await createMeeting(meetingDateAndTime, context);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        LangText.createMeeting.local,
                        style: UITexts.bigButtonText,
                      ),
                    );
                  },
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

    if (result) {
      showToast(context: context, text: 'Meeting created: ${meeting.toJson()}');
    } else {
      showToast(
        context: context,
        text: 'Create meeting failed: ${meeting.toJson()}',
        success: false,
      );
    }
  }
}
