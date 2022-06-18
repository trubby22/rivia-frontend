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
import 'package:rivia/utilities/sized_button.dart';
import 'package:rivia/utilities/time_picker.dart';
import 'package:rivia/utilities/toast.dart';

class CreateMeeting extends StatefulWidget {
  final List<Participant> allParticipants;

  const CreateMeeting({Key? key, this.allParticipants = const []})
      : super(key: key);

  @override
  State<CreateMeeting> createState() => _CreateMeetingState();
}

class _CreateMeetingState extends State<CreateMeeting> {
  final _nameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _organiserFirstNameController = TextEditingController();
  final _organiserSurnameController = TextEditingController();
  late final List<Participant> _participants = widget.allParticipants;
  bool _createParticipant = false;
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  void setDate(DateTime date) {
    setState(() {
      _date = date;
    });
  }

  void setStartTime(TimeOfDay time) {
    setState(() {
      _startTime = time;
    });
  }

  void setEndTime(TimeOfDay time) {
    setState(() {
      _endTime = time;
    });
  }

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
          ElevatedButton(
            onPressed: () async {
              await authToken.reset();
              (Navigator.of(context)..popUntil((route) => route.isFirst))
                  .popAndPushNamed(
                RouteNames.login,
              );
            },
            child: Icon(Icons.logout),
          ),
          // ignore: prefer_const_constructors
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
            // mainAxisAlignment: MainAxisAlignment.start,
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
              Row(
                children: [
                  Expanded(
                      child: Text(
                    LangText.organiser.local,
                    style: UITexts.sectionSubheader,
                  )),
                  Spacer(),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(190, 150, 100, 1),
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        filled: true,
                        labelText: LangText.firstName.local,
                      ),
                      controller: _organiserFirstNameController,
                    ),
                  ),
                  Spacer(),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromRGBO(190, 150, 100, 1),
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        filled: true,
                        labelText: LangText.surname.local,
                      ),
                      controller: _organiserSurnameController,
                    ),
                  ),
                ],
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
                  isSelected: data.value1 == _participants.length,
                  onPressed: (isSelected) {
                    if (isSelected) {
                      data.value2.clear();
                    } else {
                      data.value2.addAll(_participants);
                    }
                    context.read<MeetingBuilder>().notify();
                  },
                ),
              ),
              const SizedBox(height: 12.0),
              Column(
                children: List.generate(
                  _participants.length,
                  (index) {
                    return Row(
                      children: [
                        Selector<MeetingBuilder, Tuple2<int, Set<Participant>>>(
                          selector: (_, data) => Tuple2(
                              data.participants.length, data.participants),
                          builder: (context, data, _) => Checkbox(
                            value: data.value2.contains(
                              _participants[index],
                            ),
                            onChanged: (isSelected) {
                              if (isSelected ?? false) {
                                data.value2.add(_participants[index]);
                              } else {
                                data.value2.remove(
                                  _participants[index],
                                );
                              }
                              context.read<MeetingBuilder>().notify();
                            },
                          ),
                        ),
                        Text(_participants[index].fullName),
                      ],
                    );
                  },
                ),
              ),
              SizedButton(
                primaryColour: Colors.black,
                selectedColour: Colors.white,
                backgroundColour: Colors.blue.shade100,
                onPressedColour: Colors.blue,
                useShadow: true,
                width: 150,
                height: null,
                onPressed: (_) {
                  setState(() {
                    _createParticipant = !_createParticipant;
                  });
                },
                child: Text(
                  _createParticipant
                      ? 'Cancel participant creation'
                      : 'Create new participant',
                  style: UITexts.smallButtonText,
                ),
              ),
              const SizedBox(height: 12.0),
              if (_createParticipant)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(190, 150, 100, 1),
                                ),
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              filled: true,
                              labelText: LangText.firstName.local,
                            ),
                            controller: _firstNameController,
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(190, 150, 100, 1),
                                ),
                              ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              filled: true,
                              labelText: LangText.surname.local,
                            ),
                            controller: _surnameController,
                          ),
                        ),
                        Spacer(),
                        Expanded(
                          child: SizedButton(
                            primaryColour: Colors.black,
                            selectedColour: Colors.white,
                            backgroundColour: Colors.blue.shade100,
                            onPressedColour: Colors.blue,
                            useShadow: true,
                            width: 150,
                            onPressed: (_) {
                              if (_firstNameController.text.isNotEmpty &&
                                  _surnameController.text.isNotEmpty) {
                                String name = _firstNameController.text;
                                String surname = _surnameController.text;
                                _firstNameController.clear();
                                _surnameController.clear();
                                Participant participant =
                                    Participant(name: name, surname: surname);
                                setState(() {
                                  _participants.add(participant);
                                  _createParticipant = false;
                                });
                              }
                            },
                            child: Text(
                              'Submit participant',
                              style: UITexts.smallButtonText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                  ],
                ),
              Row(
                children: [
                  Text(LangText.date.local, style: UITexts.sectionSubheader),
                  SizedBox(width: 8.0),
                  DatePicker(
                    restorationId: 'meetingDate',
                    initialDate: _date,
                    notifyParent: setDate,
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
                  SizedBox(width: 8.0),
                  TimePicker(
                    initialTime: _startTime,
                    notifyParent: setStartTime,
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
                  SizedBox(width: 8.0),
                  TimePicker(
                    initialTime: _endTime,
                    notifyParent: setEndTime,
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
    context.read<MeetingBuilder>().organiserId = "";
    Meeting meeting = context.read<MeetingBuilder>().build();
    meeting.participants.add(
      TaggedParticipant(
        participant: Participant(
          id: "seven",
          name: _organiserFirstNameController.text,
          surname: _organiserSurnameController.text,
        ),
        notNeeded: 0,
        notPrepared: 0,
        needed: 0,
        prepared: 0,
      ),
    );
    meeting.startTime = _date.addTime(_startTime);
    meeting.endTime = _date.addTime(_endTime);

    bool result = await postMeeting(meeting);

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
