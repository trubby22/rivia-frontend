import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/date_picker.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/sized_button.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

const bigMeetingSize = 5;

class Analytics extends StatefulWidget {
  const Analytics({Key? key, required this.meetings}) : super(key: key);

  final List<Meeting> meetings;

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  int _highlightIndex = -1;
  Participant? _organiser;
  int _lowerSatisfaction = 0;
  int _upperSatisfaction = 100;
  bool _largeMeetings = false;

  final List<String> _allColumns = [
    LangText.date.local,
    LangText.startTime.local,
    LangText.endTime.local,
    LangText.organiser.local,
    LangText.noParticipants.local,
    LangText.lvlSat.local,
    LangText.neededParticipants.local,
    LangText.preparedParticipants.local,
  ];

  late List<String> _selectedColumns = _allColumns;

  final List<DropdownMenuItem<int>> _percentages =
      [0, 20, 40, 60, 80, 100].map<DropdownMenuItem<int>>((int value) {
    return DropdownMenuItem<int>(
      value: value,
      child: Text('$value %'),
    );
  }).toList();

  Widget entryBuilder(
    BuildContext context, {
    required int index,
    required String text,
  }) {
    return TableRowInkWell(
      onTap: () => Navigator.of(context).pushNamed(
        RouteNames.summary,
        arguments: widget.meetings[index],
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _highlightIndex = index),
        onExit: (_) => setState(() => _highlightIndex = -1),
        child: Container(
          height: 100.0,
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: UITexts.bigText,
            ),
          ),
        ),
      ),
    );
  }

  Widget tableBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    List<Meeting> meetings = widget.meetings;
    List<Meeting> filteredMeetings = meetings
        .where(
            (element) => _organiser == null || element.organiser == _organiser)
        .where((element) =>
            element.quality * 100 >= _lowerSatisfaction &&
            element.quality * 100 <= _upperSatisfaction)
        .where((element) =>
            !_largeMeetings || element.participants.length >= bigMeetingSize)
        .toList();

    return Align(
      child: SizedBox(
        width: width * 0.72,
        child: Table(
          border: TableBorder.all(color: Colors.grey),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {
            0: IntrinsicColumnWidth(),
            1: IntrinsicColumnWidth(),
            2: IntrinsicColumnWidth(),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Colors.blue),
              children: [
                if (_selectedColumns.contains(LangText.date.local))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      LangText.date.local,
                      textAlign: TextAlign.center,
                      style: UITexts.bigText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (_selectedColumns.contains(LangText.startTime.local))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      LangText.startTime.local,
                      textAlign: TextAlign.center,
                      style: UITexts.bigText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (_selectedColumns.contains(LangText.endTime.local))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      LangText.endTime.local,
                      textAlign: TextAlign.center,
                      style: UITexts.bigText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (_selectedColumns.contains(LangText.organiser.local))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      LangText.organiser.local,
                      textAlign: TextAlign.center,
                      style: UITexts.bigText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (_selectedColumns.contains(LangText.noParticipants.local))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      LangText.noParticipants.local,
                      textAlign: TextAlign.center,
                      style: UITexts.bigText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (_selectedColumns.contains(LangText.lvlSat.local))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      LangText.lvlSat.local,
                      textAlign: TextAlign.center,
                      style: UITexts.bigText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (_selectedColumns
                    .contains(LangText.neededParticipants.local))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      LangText.neededParticipants.local,
                      textAlign: TextAlign.center,
                      style: UITexts.bigText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (_selectedColumns
                    .contains(LangText.preparedParticipants.local))
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      LangText.preparedParticipants.local,
                      textAlign: TextAlign.center,
                      style: UITexts.bigText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            ...List.generate(
              filteredMeetings.length,
              (index) {
                final meeting = filteredMeetings[index];
                final start = meeting.startTime;
                final end = meeting.endTime;
                final organiser = meeting.organiser;
                final organiserName = organiser?.fullName ?? "[NULL]";
                final participantNum = meeting.participants.length;
                final notNeededNum =
                    meeting.participants.where((e) => e.notNeeded != 0).length;
                final notPreparedNum = meeting.participants
                    .where((e) => e.notPrepared != 0)
                    .length;

                return TableRow(
                  decoration: BoxDecoration(
                    color: _highlightIndex == index
                        ? index.isOdd
                            ? Colors.blue.shade50
                            : Colors.orange.shade50
                        : index.isOdd
                            ? const Color.fromARGB(255, 150, 210, 255)
                            : const Color.fromARGB(255, 255, 212, 150),
                  ),
                  children: [
                    if (_selectedColumns.contains(LangText.date.local))
                      entryBuilder(
                        context,
                        index: index,
                        text: '${start.day}/${start.month}/${start.year}',
                      ),
                    if (_selectedColumns.contains(LangText.startTime.local))
                      entryBuilder(
                        context,
                        index: index,
                        text: TimeOfDay.fromDateTime(start).format(context),
                      ),
                    if (_selectedColumns.contains(LangText.endTime.local))
                      entryBuilder(
                        context,
                        index: index,
                        text: TimeOfDay.fromDateTime(end).format(context),
                      ),
                    if (_selectedColumns.contains(LangText.organiser.local))
                      entryBuilder(
                        context,
                        index: index,
                        text: organiserName,
                      ),
                    if (_selectedColumns
                        .contains(LangText.noParticipants.local))
                      entryBuilder(
                        context,
                        index: index,
                        text: '$participantNum',
                      ),
                    if (_selectedColumns.contains(LangText.lvlSat.local))
                      entryBuilder(
                        context,
                        index: index,
                        text: '${(meeting.quality * 100).round()}%',
                      ),
                    if (_selectedColumns
                        .contains(LangText.neededParticipants.local))
                      entryBuilder(
                        context,
                        index: index,
                        text: '${participantNum - notNeededNum}',
                      ),
                    if (_selectedColumns
                        .contains(LangText.preparedParticipants.local))
                      entryBuilder(
                        context,
                        index: index,
                        text: '${participantNum - notPreparedNum}',
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget foregroundBuilder(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ListView(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.04),
            child: Text(
              LangText.analytics.local,
              style: UITexts.iconHeader,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(
            left: min(width * 0.07, max(0, width - 700)),
            right: min(width * 0.07, max(0, width - 700)),
            bottom: max(height * 0.05, 20.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          decoration: const BoxDecoration(
            color: Color(0xFFE6E6E6),
            borderRadius: BorderRadius.all(Radius.circular(48.0)),
            boxShadow: [BoxShadow(offset: Offset(0, 1), blurRadius: 2.0)],
          ),
          child: Column(
            children: [
              Align(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: height * 0.06, bottom: height * 0.06),
                  // width: width * 0.72,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Organiser:'),
                              SizedBox(width: 8.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(0, 1), blurRadius: 2.0)
                                  ],
                                ),
                                child: DropdownButton<Participant>(
                                  value: _organiser,
                                  underline: Container(),
                                  style: TextStyle(),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  borderRadius: BorderRadius.circular(10),
                                  elevation: 16,
                                  onChanged: (Participant? newValue) {
                                    if (newValue == _organiser) {
                                      setState(() {
                                        _organiser = null;
                                      });
                                    } else {
                                      setState(() {
                                        _organiser = newValue;
                                      });
                                    }
                                  },
                                  items: widget.meetings
                                      .map((e) => e.organiser)
                                      .map<DropdownMenuItem<Participant>>(
                                          (Participant? p) {
                                    return DropdownMenuItem<Participant>(
                                      value: p,
                                      child: Text(p?.fullName),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('From:'),
                              SizedBox(width: 8.0),
                              DatePicker(
                                  restorationId: 'analytics',
                                  meetingDateAndTime: MeetingDateAndTime()),
                              SizedBox(width: 8.0),
                              Text('To:'),
                              SizedBox(width: 8.0),
                              DatePicker(
                                  restorationId: 'analytics',
                                  meetingDateAndTime: MeetingDateAndTime()),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Meeting satisfaction between'),
                              SizedBox(width: 8.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(0, 1), blurRadius: 2.0)
                                  ],
                                ),
                                child: DropdownButton<int>(
                                  value: _lowerSatisfaction,
                                  underline: Container(),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  borderRadius: BorderRadius.circular(10),
                                  elevation: 16,
                                  onChanged: (int? newValue) {
                                    if (newValue != null &&
                                        newValue <= _upperSatisfaction) {
                                      setState(() {
                                        _lowerSatisfaction = newValue;
                                      });
                                    }
                                  },
                                  items: _percentages,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text('and'),
                              SizedBox(width: 8.0),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(0, 1), blurRadius: 2.0)
                                  ],
                                ),
                                child: DropdownButton<int>(
                                  value: _upperSatisfaction,
                                  underline: Container(),
                                  icon: const Icon(Icons.arrow_drop_down),
                                  borderRadius: BorderRadius.circular(10),
                                  elevation: 16,
                                  onChanged: (int? newValue) {
                                    if (newValue != null &&
                                        newValue >= _lowerSatisfaction) {
                                      setState(() {
                                        _upperSatisfaction = newValue;
                                      });
                                    }
                                  },
                                  items: _percentages,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              MultiSelectDialogField(
                                items: _allColumns
                                    .map((e) => MultiSelectItem(e, e))
                                    .toList(),
                                buttonText: Text('Select columns'),
                                buttonIcon: Icon(Icons.arrow_drop_down),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  border: Border.all(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                  boxShadow: [
                                    BoxShadow(
                                        offset: Offset(0, 1), blurRadius: 2.0)
                                  ],
                                ),
                                initialValue: _allColumns,
                                listType: MultiSelectListType.CHIP,
                                chipDisplay: MultiSelectChipDisplay.none(),
                                onConfirm: (values) {
                                  _selectedColumns =
                                      values.map((e) => e as String).toList();
                                },
                              ),
                              SizedBox(width: 8.0),
                              SizedButton(
                                primaryColour: Colors.black,
                                selectedColour: Colors.white,
                                backgroundColour: Colors.blue.shade100,
                                onPressedColour: Colors.blue,
                                useShadow: true,
                                width: 150,
                                height: null,
                                isSelected: _largeMeetings,
                                onPressed: (_) {
                                  setState(() {
                                    _largeMeetings = !_largeMeetings;
                                  });
                                },
                                child: Text(
                                  'Large meetings',
                                  style: UITexts.smallButtonText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              tableBuilder(context),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/general_bg.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill,
          ),
          foregroundBuilder(context),
          LanguageSwitcher(callback: () => setState(() => {})),
          Positioned(
            bottom: 32.0,
            right: 64.0,
            child: SizedButton(
              backgroundColour: const Color.fromRGBO(239, 198, 135, 1),
              primaryColour: Colors.black,
              onPressedColour: const Color.fromRGBO(239, 198, 135, 1),
              height: null,
              width: null,
              padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
              child: Text("Create New Meeting", style: UITexts.bigButtonText),
              onPressed: (_) => Navigator.of(context).pushNamed(
                RouteNames.createMeeting,
                arguments: [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
