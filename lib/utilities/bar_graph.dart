import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/widget_size.dart';

class BarGraphListener with ChangeNotifier {
  BarGraphListener();

  int _highlightedBarIndex = -1;

  int get highlightedBarIndex => _highlightedBarIndex;

  set highlightedBarIndex(int index) {
    _highlightedBarIndex = index;
    notifyListeners();
  }
}

/// The bar graph showing friends' speciaties.
class BarGraph extends StatefulWidget {
  const BarGraph({
    Key? key,
    required this.dicts,
    this.callback,
  }) : super(key: key);

  final Map<Participant, int> dicts;

  final List<Widget>? Function(Participant participant)? callback;

  @override
  _BarGraphState createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {
  /// The index of the highlighted button.
  int _highlightIndex = 0;

  /// The height of this widget.
  double? _height;

  double entryHeight = 0.0;

  /// The number of entries displayed corresponding to each button.
  static const _topNList = [5, 10, 100];

  /// Ordered map from nubmer of occurrences.
  late final SplayTreeMap<int, List<Participant>> _sortedRanks =
      _process(widget.dicts);

  /// Keys of [_sortedRanks].
  late final _rankCounts = _sortedRanks.keys.toList();

  /// The number of ranks with each nubmer of occurrences.
  late final _ranksPerCount =
      _sortedRanks.values.map((list) => list.length).toList();

  /// The total number of distinct ranks.
  late final _totalSpecialtiesCount =
      _sortedRanks.values.fold<int>(0, (value, list) => value + list.length);

  final graphButtonHeight = 20.0;
  final titlePanelHeight = 20.0;
  final attributeWidth = 150.0;

  /// The separator [Widget] between consecutive entries.
  late final _barSeparator = Row(
    children: const [
      SizedBox(height: 24.0),
      Expanded(child: SizedBox()),
    ],
  );

  SplayTreeMap<int, List<Participant>> _process(Map<Participant, int> map) {
    SplayTreeMap<int, List<Participant>> res = SplayTreeMap.of({});

    for (final participant in map.keys) {
      final count = map[participant]!;
      if (res.containsKey(count)) {
        res[count]!.add(participant);
      } else {
        res[count] = [participant];
      }
    }

    return res;
  }

  Size _getTextSize(String text) => (TextPainter(
        text: TextSpan(text: text),
        textDirection: TextDirection.ltr,
      )..layout())
          .size;

  Widget _graphButtonBuilder({
    required String text,
    required int index,
  }) =>
      Container(
        margin: const EdgeInsets.only(left: 16.0),
        height: graphButtonHeight,
        width: _getTextSize(text).width + graphButtonHeight / 2,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor:
                (_highlightIndex == index) ? Colors.blue : Colors.grey,
            splashFactory: NoSplash.splashFactory,
            shape: const StadiumBorder(),
          ),
          onPressed: () => setState(() {
            _highlightIndex = index;
          }),
          child: Text(text, textAlign: TextAlign.center),
        ),
      );

  Widget _barGraphBuilder(int? showCount) {
    // TODO: No Friend Scenario
    if (_sortedRanks.isEmpty) return const SizedBox();

    final maxCount = _sortedRanks.lastKey()!;
    final entryCount = showCount != null
        ? min(showCount, _totalSpecialtiesCount)
        : _totalSpecialtiesCount;

    final entryWidgetList = Iterable<int>.generate(entryCount).map(
      (index) {
        {
          final originalIndex = index;
          int countIndex = _sortedRanks.length - 1;
          while (index >= _ranksPerCount[countIndex]) {
            index -= _ranksPerCount[countIndex];
            countIndex--;
          }
          int count = _rankCounts[countIndex];
          Participant participant = _sortedRanks[count]![index];

          // MARK: Bar Entries
          return _barEntryBuilder(count, maxCount, participant, originalIndex);
        }
      },
    );

    return ChangeNotifierProvider<BarGraphListener>(
      create: (_) => BarGraphListener(),
      child: Stack(
        children: [
          WidgetSize(
            onChange: (size) {
              if (size != null) {
                setState(() => entryHeight = size.height);
              }
            },
            child: Column(
              children: entryWidgetList
                  .expand((entry) => [_barSeparator, entry])
                  .skip(1)
                  .toList()
                ..add(const SizedBox(height: 8.0)),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10.0),
            height: entryHeight,
            width: 0.5,
          ),
        ],
      ),
    );
  }

  Widget _barEntryBuilder(
      int count, int maxCount, Participant participant, int index) {
    double proportion = count / maxCount;

    return Consumer<BarGraphListener>(
      builder: (context, data, _) {
        return GestureDetector(
          onTap: () {
            if (data.highlightedBarIndex == index) {
              data.highlightedBarIndex = -1;
              final associatedParticipants = widget.callback?.call(participant);
              if (associatedParticipants != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    ),
                    contentPadding: const EdgeInsets.all(12.0),
                    title: Text(LangText.voters.local),
                    content: SingleChildScrollView(
                      child: ListTileTheme(
                        child: ListBody(children: associatedParticipants),
                      ),
                    ),
                  ),
                );
              }
            } else {
              data.highlightedBarIndex = index;
            }
          },
          child: Row(
            children: [
              // MARK: Specialty Name
              Container(
                width: attributeWidth,
                height: 20.0,
                alignment: Alignment.centerRight,
                child: Text(
                  participant.fullName,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: index == data.highlightedBarIndex
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                padding: const EdgeInsets.only(left: 10.0, right: 7.0),
              ),
              const SizedBox(width: 8.0),
              // MARK: Specialty Bar
              Expanded(
                flex: (proportion * 100).toInt(),
                child: Container(
                  height: 14.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: index == data.highlightedBarIndex
                        ? Colors.blue
                        : Colors.lightBlue,
                  ),
                ),
              ),
              Expanded(
                flex: 100 - (proportion * 100).toInt(),
                child: const SizedBox(),
              ),
              // MARK: Explicit Specialty Count
              _numberBuilder(index == data.highlightedBarIndex, count),
            ],
          ),
        );
      },
    );
  }

  Widget _numberBuilder(bool isActive, int count) {
    if (isActive) {
      return Container(
        width: 48.0,
        padding: const EdgeInsets.only(left: 4.0),
        alignment: Alignment.centerLeft,
        child: Text(count.toString()),
      );
    }

    return const SizedBox(width: 48.0);
  }

  @override
  Widget build(BuildContext context) {
    return WidgetSize(
      onChange: (size) {
        setState(() => _height = size?.height);
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 18.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            SizedBox(height: titlePanelHeight),
            // MARK: Bar Graph Title
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     // MARK: TOP 5 Button
            //     _graphButtonBuilder(
            //       text: "5",
            //       index: 0,
            //     ),
            //     // MARK: TOP 10 Button
            //     _graphButtonBuilder(
            //       text: "10",
            //       index: 1,
            //     ),
            //     // MARK: ALL Button
            //     _graphButtonBuilder(
            //       text: "100",
            //       index: 2,
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 12.0),
            // MARK: Bar Graph Content
            _barGraphBuilder(null),
          ],
        ),
      ),
    );
  }
}
