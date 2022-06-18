import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/utilities/widget_size.dart';

class Tuple implements Comparable<Tuple> {
  const Tuple(this.value1, this.value2);

  final double value1;
  final int value2;

  @override
  int compareTo(Tuple other) {
    final cmp1 = value1.compareTo(other.value1);

    if (cmp1 != 0) {
      return cmp1;
    }

    return value2.compareTo(other.value2);
  }
}

/// The bar graph showing friends' speciaties.
class BarGraph extends StatefulWidget {
  const BarGraph({
    Key? key,
    required this.dicts,
    this.nameSectionWidth = 150.0,
    this.numberSectionWidth = 48.0,
    this.rowHeight = 36.0,
    this.seperatorHeight = 12.0,
    this.callback,
    this.responseCount,
  }) : super(key: key);

  final Map<Participant, int> dicts;
  final List<Widget>? Function(Participant participant)? callback;
  final double nameSectionWidth;
  final double numberSectionWidth;
  final double rowHeight;
  final double seperatorHeight;
  final Map<Participant, int>? responseCount;

  @override
  _BarGraphState createState() => _BarGraphState();
}

class _BarGraphState extends State<BarGraph> {
  /// The index of the highlighted button.
  int _highlightIndex = 0;

  /// The height of this widget.
  double? _height;

  double entryHeight = 0.0;

  /// Ordered map from nubmer of occurrences.
  late final SplayTreeMap<Tuple, List<Participant>> _sortedRanks =
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

  /// The separator [Widget] between consecutive entries.
  late final _barSeparator = Row(
    children: [
      SizedBox(height: widget.seperatorHeight),
      const Expanded(child: SizedBox()),
    ],
  );

  SplayTreeMap<Tuple, List<Participant>> _process(
    Map<Participant, int> map,
  ) {
    SplayTreeMap<Tuple, List<Participant>> res = SplayTreeMap.of({});

    for (final participant in map.keys) {
      final count = map[participant]!;
      final percentage = count / (widget.responseCount?[participant] ?? 1);
      final tuple = Tuple(percentage, count);
      if (res.containsKey(tuple)) {
        res[tuple]!.add(participant);
      } else {
        res[tuple] = [participant];
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

    final maxCount = _sortedRanks.lastKey()!.value2;
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
          final count = _rankCounts[countIndex];
          Participant participant = _sortedRanks[count]![index];

          // MARK: Bar Entries
          return _barEntryBuilder(count, maxCount, participant, originalIndex);
        }
      },
    );

    return Stack(
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
    );
  }

  Widget _barEntryBuilder(
    Tuple count,
    int maxCount,
    Participant participant,
    int index,
  ) {
    double proportion = count.value1;

    return Row(
      children: [
        Container(
          width: widget.nameSectionWidth,
          height: widget.rowHeight,
          alignment: Alignment.centerRight,
          child: Text(
            participant.fullName,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: UITexts.mediumText,
            maxLines: 2,
          ),
          // padding: const EdgeInsets.only(left: 10.0, right: 7.0),
        ),
        const SizedBox(width: 8.0),
        // MARK: Specialty Bar
        Expanded(
          flex: (proportion * 100).toInt(),
          child: Container(
            height: widget.rowHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(widget.rowHeight / 2),
                bottomRight: Radius.circular(widget.rowHeight / 2),
              ),
              color: Colors.blue,
            ),
          ),
        ),
        Expanded(
          flex: 100 - (proportion * 100).toInt(),
          child: const SizedBox(),
        ),
        Container(
          width: widget.numberSectionWidth,
          padding: const EdgeInsets.only(left: 12.0),
          alignment: Alignment.centerLeft,
          child: Text(widget.responseCount == null
              ? count.value2.toString()
              : '${(count.value1 * 100).toInt()}%'),
        ),
      ],
    );
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
