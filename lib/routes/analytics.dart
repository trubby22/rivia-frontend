import 'dart:math';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/date_picker.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/log_out_button.dart';
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
  late Participant? _organiser = allParticipants;
  int _lowerSatisfaction = 0;
  int _upperSatisfaction = 100;
  bool _multiselect = false;
  late List<Meeting> _filteredMeetings = widget.meetings;
  late List<bool> _selectedMeetings =
      List.generate(_filteredMeetings.length, (index) => false);
  Participant? allParticipants =
      Participant(name: LangText.all.local, surname: '');
  final columnWidths = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  late final Map<int, String?> headerCache = Map.fromEntries(
    columnWidths.mapIndexed((i, _) => MapEntry(i, null)),
  );
  late final List<Map<int, String?>> entryCache = List.filled(
    widget.meetings.length,
    Map.fromEntries(columnWidths.mapIndexed((i, _) => MapEntry(i, null))),
  );

  final List<LangText> _allColumns = [
    LangText.date,
    LangText.startTime,
    LangText.endTime,
    LangText.organiser,
    LangText.noParticipants,
    LangText.lvlSat,
    LangText.neededParticipants,
    LangText.preparedParticipants,
    LangText.meetingName,
  ];

  late List<LangText> _selectedColumns = _allColumns;

  final List<DropdownMenuItem<int>> _percentages =
      [0, 20, 40, 60, 80, 100].map<DropdownMenuItem<int>>((int value) {
    return DropdownMenuItem<int>(
      value: value,
      child: Text('$value %'),
    );
  }).toList();

  DateTime _startDate = DateTime.now().subtract(Duration(days: 28));
  DateTime _endDate = DateTime.now().add(Duration(days: 28));

  void setStartDate(DateTime date) {
    setState(() {
      _startDate = date;
    });
  }

  void setEndDate(DateTime date) {
    setState(() {
      _endDate = date;
    });
  }

  Size _getTextSize(String text) => (TextPainter(
        text: TextSpan(text: text, style: UITexts.mediumText),
        textDirection: TextDirection.ltr,
      )..layout())
          .size;

  String _render(String text, int column) {
    final texts = text.split(' ');

    final rows = <String>[];

    columnWidths[column] = max(
      MediaQuery.of(context).size.width * 0.8 / _selectedColumns.length,
      columnWidths[column],
    );

    for (final t in texts) {
      columnWidths[column] = max(_getTextSize(t).width, columnWidths[column]);
    }

    if (text.length <= 1) {
      rows.addAll(texts);
    } else {
      rows.add(texts[0]);
      texts.removeAt(0);

      for (final t in texts) {
        if (_getTextSize(rows.last + ' ' + t).width >= columnWidths[column]) {
          rows.add(t);
        } else {
          rows.last = rows.last + ' ' + t;
        }
      }
    }
    return rows.join('\n');
  }

  Widget headerBuilder(
    BuildContext context, {
    required String text,
    required int column,
  }) {
    final String renderedText = headerCache[column] ?? _render(text, column);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        renderedText,
        textAlign: TextAlign.center,
        style: UITexts.mediumText.copyWith(color: Colors.white),
      ),
    );
  }

  Widget entryBuilder(
    BuildContext context, {
    required int index,
    required String text,
    required int column,
  }) {
    final String renderedText =
        entryCache[index][column] ?? _render(text, column);

    return TableRowInkWell(
      onTap: () async {
        Meeting meeting = _filteredMeetings[index];
        if (_multiselect) {
          _selectedMeetings[index] = !_selectedMeetings[index];
        } else {
          final isReviewed = await getIsReviewed(meeting.meetingId!);
          Navigator.of(context)
              .pushNamed(
            isReviewed ? RouteNames.summary : RouteNames.review,
            arguments: isReviewed ? [meeting] : meeting,
          )
              .then((_) async {
            final meetingIds = await getMeetings().onError(
              (error, stackTrace) => Future.value([]),
            );
            final meetings =
                (await Future.wait(meetingIds.map((f) => getMeetingContent(f))))
                    .cast<Meeting>();
            widget.meetings.clear();
            setState(() => widget.meetings.addAll(meetings));
          });
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _highlightIndex = index),
        onExit: (_) => setState(() => _highlightIndex = -1),
        child: Container(
          height: 100.0,
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              renderedText,
              textAlign: TextAlign.center,
              style: UITexts.mediumText,
            ),
          ),
        ),
      ),
    );
  }

  Widget tableBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    List<Meeting> meetings = widget.meetings;
    _filteredMeetings = meetings
        .where((element) =>
            _organiser == allParticipants || element.organiser == _organiser)
        .where((element) {
          if (element.qualities.isEmpty) {
            return true;
          }
          return element.qualities.reduce((a, b) => a + b) /
                      element.qualities.length *
                      100 >=
                  _lowerSatisfaction &&
              element.qualities.reduce((a, b) => a + b) /
                      element.qualities.length *
                      100 <=
                  _upperSatisfaction;
        })
        .where((element) =>
            (element.startTime.isAfter(_startDate) ||
                element.startTime.isAtSameMomentAs(_startDate)) &&
            (element.endTime.isBefore(_endDate) ||
                element.endTime.isAtSameMomentAs(_endDate)))
        .toList();

    return SizedBox(
      width: width * 0.8,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: Colors.grey),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            defaultColumnWidth: IntrinsicColumnWidth(),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Colors.blue),
                children: [
                  if (_selectedColumns.contains(LangText.meetingName))
                    headerBuilder(
                      context,
                      text: LangText.meetingName.local,
                      column: 0,
                    ),
                  if (_selectedColumns.contains(LangText.date))
                    headerBuilder(
                      context,
                      text: LangText.date.local,
                      column: 1,
                    ),
                  if (_selectedColumns.contains(LangText.startTime))
                    headerBuilder(
                      context,
                      text: LangText.startTime.local,
                      column: 2,
                    ),
                  if (_selectedColumns.contains(LangText.endTime))
                    headerBuilder(
                      context,
                      text: LangText.endTime.local,
                      column: 3,
                    ),
                  if (_selectedColumns.contains(LangText.organiser))
                    headerBuilder(
                      context,
                      text: LangText.organiser.local,
                      column: 4,
                    ),
                  if (_selectedColumns.contains(LangText.noParticipants))
                    headerBuilder(
                      context,
                      text: LangText.noParticipants.local,
                      column: 5,
                    ),
                  if (_selectedColumns.contains(LangText.lvlSat))
                    headerBuilder(
                      context,
                      text: LangText.lvlSat.local,
                      column: 6,
                    ),
                  if (_selectedColumns.contains(LangText.neededParticipants))
                    headerBuilder(
                      context,
                      text: LangText.neededParticipants.local,
                      column: 7,
                    ),
                  if (_selectedColumns.contains(LangText.preparedParticipants))
                    headerBuilder(
                      context,
                      text: LangText.preparedParticipants.local,
                      column: 8,
                    ),
                ],
              ),
              ...List.generate(
                _filteredMeetings.length,
                (index) {
                  final meeting = _filteredMeetings[index];
                  final name = meeting.title;
                  final start = meeting.startTime;
                  final end = meeting.endTime;
                  final organiser = meeting.organiser;
                  final organiserName = organiser?.fullName ?? "[NULL]";
                  final participantNum = meeting.participants.length;
                  final notNeededNum = meeting.participants
                      .where((e) => e.notNeeded != 0)
                      .length;
                  final notPreparedNum = meeting.participants
                      .where((e) => e.notPrepared != 0)
                      .length;

                  return TableRow(
                    decoration: BoxDecoration(
                      color: _selectedMeetings[index]
                          ? Colors.green.shade200
                          : _highlightIndex == index
                              ? index.isOdd
                                  ? Colors.blue.shade50
                                  : Colors.orange.shade50
                              : index.isOdd
                                  ? const Color.fromARGB(255, 150, 210, 255)
                                  : const Color.fromARGB(255, 255, 212, 150),
                    ),
                    children: [
                      if (_selectedColumns.contains(LangText.meetingName))
                        entryBuilder(
                          context,
                          index: index,
                          text: name,
                          column: 0,
                        ),
                      if (_selectedColumns.contains(LangText.date))
                        entryBuilder(
                          context,
                          index: index,
                          text: '${start.day}.${start.month}.${start.year}',
                          column: 1,
                        ),
                      if (_selectedColumns.contains(LangText.startTime))
                        entryBuilder(
                          context,
                          index: index,
                          text: TimeOfDay.fromDateTime(start)
                              .format(context)
                              .replaceAll(' ', '\u{00A0}'),
                          column: 2,
                        ),
                      if (_selectedColumns.contains(LangText.endTime))
                        entryBuilder(
                          context,
                          index: index,
                          text: TimeOfDay.fromDateTime(end)
                              .format(context)
                              .replaceAll(' ', '\u{00A0}'),
                          column: 3,
                        ),
                      if (_selectedColumns.contains(LangText.organiser))
                        entryBuilder(
                          context,
                          index: index,
                          text: organiserName,
                          column: 4,
                        ),
                      if (_selectedColumns.contains(LangText.noParticipants))
                        entryBuilder(
                          context,
                          index: index,
                          text: '$participantNum',
                          column: 5,
                        ),
                      if (_selectedColumns.contains(LangText.lvlSat))
                        entryBuilder(
                          context,
                          index: index,
                          text:
                              '${meeting.qualities.isEmpty ? 50 : (meeting.qualities.reduce((a, b) => a + b) / meeting.qualities.length * 100).round()}%',
                          column: 6,
                        ),
                      if (_selectedColumns
                          .contains(LangText.neededParticipants))
                        entryBuilder(
                          context,
                          index: index,
                          text: '${participantNum - notNeededNum}',
                          column: 7,
                        ),
                      if (_selectedColumns
                          .contains(LangText.preparedParticipants))
                        entryBuilder(
                          context,
                          index: index,
                          text: '${participantNum - notPreparedNum}',
                          column: 8,
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('${LangText.organiser.local}:'),
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
                                  onChanged: _multiselect
                                      ? null
                                      : (Participant? newValue) {
                                          setState(() {
                                            _organiser = newValue;
                                          });
                                        },
                                  items: (widget.meetings
                                          .map((e) => e.organiser)
                                          .toList()
                                        ..insert(0, allParticipants))
                                      .map<DropdownMenuItem<Participant>>(
                                          (Participant? p) {
                                    return DropdownMenuItem<Participant>(
                                      value: p,
                                      child: Text(p?.fullName),
                                    );
                                  }).toList(),
                                ),
                              ),
                              SizedBox(width: 8.0),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${LangText.from.local}:'),
                              SizedBox(width: 8.0),
                              DatePicker(
                                restorationId: 'analytics',
                                initialDate: _startDate,
                                notifyParent: setStartDate,
                                enabled: !_multiselect,
                              ),
                              SizedBox(width: 8.0),
                              Text('${LangText.to.local}:'),
                              SizedBox(width: 8.0),
                              DatePicker(
                                restorationId: 'analytics',
                                initialDate: _endDate,
                                notifyParent: setEndDate,
                                enabled: !_multiselect,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(LangText.meetingSatisfactionBetween.local),
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
                                  onChanged: _multiselect
                                      ? null
                                      : (int? newValue) {
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
                              Text(LangText.and.local),
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
                                  onChanged: _multiselect
                                      ? null
                                      : (int? newValue) {
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
                              SizedBox(width: 8.0),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MultiSelectDialogField(
                                items: _allColumns
                                    .map((e) => MultiSelectItem(e, e.local))
                                    .toList(),
                                buttonText: Text(LangText.selectColumns.local),
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
                                  setState(() {
                                    headerCache.clear();
                                    for (final cache in entryCache) {
                                      cache.clear();
                                    }
                                    _selectedColumns = values
                                        .map((e) => e as LangText)
                                        .toList();
                                  });
                                },
                              ),
                              SizedBox(width: 8.0),
                              // SizedButton(
                              //   primaryColour: Colors.black,
                              //   selectedColour: Colors.white,
                              //   backgroundColour: Colors.blue.shade100,
                              //   onPressedColour: Colors.blue,
                              //   useShadow: true,
                              //   width: 150,
                              //   height: null,
                              //   isSelected: _largeMeetings,
                              //   onPressed: _multiselect
                              //       ? null
                              //       : (_) {
                              //           setState(() {
                              //             _largeMeetings = !_largeMeetings;
                              //           });
                              //         },
                              //   child: Text(
                              //     LangText.largeMeetings.local,
                              //     style: UITexts.smallButtonText,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
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
                                _selectedMeetings = List.generate(
                                    _filteredMeetings.length, (index) => false);
                                _multiselect = !_multiselect;
                              });
                            },
                            child: Text(
                              _multiselect
                                  ? LangText.cancelMultiUser.local
                                  : LangText.multiSelect.local,
                              style: UITexts.smallButtonText,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          if (_multiselect)
                            SizedButton(
                              primaryColour: Colors.black,
                              selectedColour: Colors.white,
                              backgroundColour: Colors.blue.shade100,
                              onPressedColour: Colors.blue,
                              useShadow: true,
                              width: 150,
                              height: null,
                              onPressed: (_) {
                                print(_selectedMeetings);
                                Navigator.of(context).pushNamed(
                                    RouteNames.summary,
                                    arguments: IterableZip([
                                      _filteredMeetings,
                                      _selectedMeetings
                                    ])
                                        .where((element) => element[1] as bool)
                                        .map((e) => e[0] as Meeting)
                                        .toList());
                              },
                              child: Text(
                                LangText.showMultiSelectSummary.local,
                                style: UITexts.smallButtonText,
                              ),
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
          const LogOutButton(),
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
              child: Text(LangText.createNewMeeting.local,
                  style: UITexts.bigButtonText),
              onPressed: _multiselect
                  ? null
                  : (_) => Navigator.of(context).pushNamed(
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
