import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:rivia/constants/fields.dart';
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
import 'package:web_socket_channel/web_socket_channel.dart';

const bigMeetingSize = 5;

class Analytics extends StatefulWidget {
  const Analytics({Key? key, required this.meetings}) : super(key: key);

  final List<Meeting> meetings;

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  String? _highlightId;
  late Participant? _organiser = allParticipants;
  int _lowerSatisfaction = 0;
  int _upperSatisfaction = 100;
  bool get _multiselect => _selectedMeetings.isNotEmpty;
  late Map<String, Meeting> _filteredMeetings = Map.fromEntries(
    widget.meetings.map((m) => MapEntry(m.meetingId!, m)),
  );
  final Map<String, Meeting> _selectedMeetings = {};
  final allParticipants = Participant(name: LangText.all.local, surname: '');
  final columnWidths = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
  late final Map<int, String?> headerCache = Map.fromEntries(
    columnWidths.mapIndexed((i, _) => MapEntry(i, null)),
  );
  late final Map<String, Map<int, String?>> entryCache = Map.fromEntries(
    widget.meetings.map(
      (m) => MapEntry(
        m.meetingId!,
        Map.fromEntries(columnWidths.mapIndexed((i, _) => MapEntry(i, null))),
      ),
    ),
  );

  WebSocketChannel? _webSocket;

  final List<LangText> _allColumns = [
    LangText.date,
    LangText.organiser,
    LangText.startTime,
    LangText.endTime,
    LangText.lvlSat,
    LangText.noParticipants,
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

  String _render(String text, int? column) {
    if (column == null) {
      return text;
    }

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
    int? column,
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
    required String id,
    required String text,
    int? column,
  }) {
    final String renderedText =
        entryCache[id]![column] ?? _render(text, column);

    return TableRowInkWell(
      onTap: () async {
        Meeting meeting = _filteredMeetings[id]!;

        final isReviewed = await getIsReviewed(meeting.meetingId!);
        Navigator.of(context).pushNamed(
          isReviewed ? RouteNames.summary : RouteNames.review,
          arguments: isReviewed ? [meeting] : meeting,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _highlightId = id),
        onExit: (_) => setState(() => _highlightId = null),
        child: Container(
          height: 72.0,
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
    _filteredMeetings = Map.fromEntries(meetings
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
        .where(
          (element) =>
              (element.startTime.isAfter(_startDate) ||
                  element.startTime.isAtSameMomentAs(_startDate)) &&
              (element.endTime.isBefore(_endDate.add(
                      const Duration(hours: 23, minutes: 59, seconds: 59))) ||
                  element.endTime.isAtSameMomentAs(_endDate.add(
                      const Duration(hours: 23, minutes: 59, seconds: 59)))),
        )
        .map((m) => MapEntry(m.meetingId!, m)));
    return SizedBox(
      width: width * 0.8,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: Colors.grey),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Colors.blue),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Checkbox(
                        onChanged: (value) => setState(() {
                          if (value ?? false) {
                            _selectedMeetings.addAll(_filteredMeetings);
                          } else {
                            _selectedMeetings.clear();
                          }
                        }),
                        value: _selectedMeetings.isNotEmpty,
                      ),
                    ),
                  ),
                  if (_selectedColumns.contains(LangText.meetingName))
                    headerBuilder(
                      context,
                      text: LangText.meetingName.local,
                      column: 0,
                    ),
                  if (_selectedColumns.contains(LangText.organiser))
                    headerBuilder(
                      context,
                      text: LangText.organiser.local,
                      column: 1,
                    ),
                  if (_selectedColumns.contains(LangText.date))
                    headerBuilder(
                      context,
                      text: LangText.date.local,
                      column: 2,
                    ),
                  if (_selectedColumns.contains(LangText.startTime))
                    headerBuilder(
                      context,
                      text: LangText.startTime.local,
                      column: 3,
                    ),
                  if (_selectedColumns.contains(LangText.endTime))
                    headerBuilder(
                      context,
                      text: LangText.endTime.local,
                      column: 4,
                    ),
                  if (_selectedColumns.contains(LangText.lvlSat))
                    headerBuilder(
                      context,
                      text: LangText.lvlSat.local,
                      column: 5,
                    ),
                  if (_selectedColumns.contains(LangText.noParticipants))
                    headerBuilder(
                      context,
                      text: LangText.noParticipants.local,
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
              ..._filteredMeetings.entries.mapIndexed((index, entry) {
                final meeting = entry.value;
                final name = meeting.title;
                final start = meeting.startTime;
                final end = meeting.endTime;
                final organiser = meeting.organiser;
                final organiserName = organiser?.fullName ?? "[NULL]";
                final participantNum = meeting.participants.length;
                final neededNum =
                    meeting.participants.where((e) => e.needed != 0).length;
                final preparedNum =
                    meeting.participants.where((e) => e.prepared != 0).length;

                return TableRow(
                  decoration: BoxDecoration(
                    color: _highlightId == entry.key
                        ? index.isOdd
                            ? Colors.blue.shade50
                            : Colors.orange.shade50
                        : index.isOdd
                            ? const Color.fromARGB(255, 150, 210, 255)
                            : const Color.fromARGB(255, 255, 212, 150),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: 72.0,
                        child: Center(
                          child: Checkbox(
                            onChanged: (value) => setState(() {
                              if (value ?? false) {
                                _selectedMeetings[entry.key] = meeting;
                              } else {
                                _selectedMeetings.remove(entry.key);
                              }
                            }),
                            value: _selectedMeetings.containsKey(entry.key),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedColumns.contains(LangText.meetingName))
                      entryBuilder(
                        context,
                        id: entry.key,
                        text: name,
                        column: 0,
                      ),
                    if (_selectedColumns.contains(LangText.organiser))
                      entryBuilder(
                        context,
                        id: entry.key,
                        text: organiserName,
                        column: 1,
                      ),
                    if (_selectedColumns.contains(LangText.date))
                      entryBuilder(
                        context,
                        id: entry.key,
                        text: '${start.day}.${start.month}.${start.year}',
                        column: 2,
                      ),
                    if (_selectedColumns.contains(LangText.startTime))
                      entryBuilder(
                        context,
                        id: entry.key,
                        text: TimeOfDay.fromDateTime(start)
                            .format(context)
                            .replaceAll(' ', '\u{00A0}'),
                        column: 3,
                      ),
                    if (_selectedColumns.contains(LangText.endTime))
                      entryBuilder(
                        context,
                        id: entry.key,
                        text: TimeOfDay.fromDateTime(end)
                            .format(context)
                            .replaceAll(' ', '\u{00A0}'),
                        column: 4,
                      ),
                    if (_selectedColumns.contains(LangText.lvlSat))
                      entryBuilder(
                        context,
                        id: entry.key,
                        text:
                            '${meeting.qualities.isEmpty ? 50 : (meeting.qualities.reduce((a, b) => a + b) / meeting.qualities.length * 100).round()}%',
                        column: 5,
                      ),
                    if (_selectedColumns.contains(LangText.noParticipants))
                      entryBuilder(
                        context,
                        id: entry.key,
                        text: '$participantNum',
                        column: 6,
                      ),
                    if (_selectedColumns.contains(LangText.neededParticipants))
                      entryBuilder(
                        context,
                        id: entry.key,
                        text: '$neededNum',
                        column: 7,
                      ),
                    if (_selectedColumns
                        .contains(LangText.preparedParticipants))
                      entryBuilder(
                        context,
                        id: entry.key,
                        text: '$preparedNum',
                        column: 8,
                      ),
                  ],
                );
              }).toList(),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${LangText.organiser.local}:'),
                      SizedBox(width: 8.0),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          border: Border.all(
                            color: Colors.transparent,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(20),
                          ),
                          boxShadow: const [
                            BoxShadow(offset: Offset(0, 1), blurRadius: 2.0),
                          ],
                        ),
                        child: DropdownButton<Participant>(
                          alignment: Alignment.center,
                          value: _organiser,
                          underline: Container(),
                          icon: const Icon(Icons.arrow_drop_down),
                          borderRadius: BorderRadius.circular(10.0),
                          elevation: 16,
                          onChanged: (Participant? newValue) {
                            setState(() => _organiser = newValue);
                          },
                          items: (widget.meetings
                                  .map((e) => e.organiser)
                                  .toSet()
                                  .toList()
                                ..insert(0, allParticipants))
                              .map<DropdownMenuItem<Participant>>(
                                  (Participant? p) {
                            return DropdownMenuItem<Participant>(
                              value: p,
                              child: Text(
                                p?.fullName,
                                style: UITexts.mediumText,
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(width: width * 0.02),
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
                            BoxShadow(offset: Offset(0, 1), blurRadius: 2.0)
                          ],
                        ),
                        child: DropdownButton<int>(
                          value: _lowerSatisfaction,
                          alignment: Alignment.center,
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
                            BoxShadow(offset: Offset(0, 1), blurRadius: 2.0),
                          ],
                        ),
                        child: DropdownButton<int>(
                          value: _upperSatisfaction,
                          alignment: Alignment.center,
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
                      SizedBox(width: width * 0.02),
                      Text('${LangText.from.local}:'),
                      SizedBox(width: 8.0),
                      DatePicker(
                        restorationId: 'analytics',
                        initialDate: _startDate,
                        notifyParent: setStartDate,
                      ),
                      SizedBox(width: 8.0),
                      Text('${LangText.to.local}:'),
                      SizedBox(width: 8.0),
                      DatePicker(
                        restorationId: 'analytics',
                        initialDate: _endDate,
                        notifyParent: setEndDate,
                      ),
                      SizedBox(width: width * 0.02),
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
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: [
                            BoxShadow(offset: Offset(0, 1), blurRadius: 2.0)
                          ],
                        ),
                        initialValue: _allColumns,
                        listType: MultiSelectListType.CHIP,
                        chipDisplay: MultiSelectChipDisplay.none(),
                        onConfirm: (values) {
                          setState(() {
                            headerCache.clear();
                            for (final value in entryCache.values) {
                              value.clear();
                            }

                            _selectedColumns =
                                values.map((e) => e as LangText).toList();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
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
                    setState(() {
                      Navigator.of(context).pushNamed(
                        RouteNames.summary,
                        arguments: _selectedMeetings.values.toList(),
                      );
                    });
                  },
                  child: Text(
                    LangText.showMultiSelectSummary.local,
                    style: UITexts.smallButtonText,
                  ),
                ),
              SizedBox(height: height * 0.02),
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
          StreamBuilder(
            stream: _webSocket?.stream,
            builder: (context, snapshot) {
              if (snapshot.data != null) {
                Map<String, dynamic> content =
                    json.decode(snapshot.data!.toString());
                content[Fields.meeting][Fields.meetingId] = content[Fields.id];
                content = content[Fields.meeting];
                final newMeeting = Meeting.fromJson(content);

                widget.meetings.removeWhere(
                  (m) => m.meetingId == newMeeting?.meetingId,
                );
                if (newMeeting != null) {
                  widget.meetings.add(newMeeting);
                  entryCache[newMeeting.meetingId!] = Map.fromEntries(
                    columnWidths.mapIndexed((i, _) => MapEntry(i, null)),
                  );
                }
                widget.meetings.sortBy((m) => m.startTime);
              }
              return foregroundBuilder(context);
            },
          ),
          const LogOutButton(),
          LanguageSwitcher(
            callback: () => setState(
              () {
                headerCache.clear();
                for (final value in entryCache.values) {
                  value.clear();
                }
              },
            ),
          ),
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

  @override
  void initState() {
    super.initState();
    _webSocket = getWebSocket();
  }

  @override
  void dispose() {
    disposeWebSocket();
    super.dispose();
  }
}
