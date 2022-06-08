import 'dart:math';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/sized_button.dart';

class Review extends StatefulWidget {
  final Meeting meeting;
  final Participant participant;

  const Review({
    Key? key,
    required this.meeting,
    required this.participant,
  }) : super(key: key);

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final TextEditingController _controller = TextEditingController();

  /// Build the checkboxes that vote each participant not needed or not prepared.
  Widget participantSelectionBuilder(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120.0,
              height: 40.0,
              child: Center(
                child: Text(
                  LangText.notNeeded.local,
                  style: UITexts.mediumText,
                ),
              ),
            ),
            Selector<ResponseBuilder, Tuple2<int, Set<Participant>>>(
              selector: (_, data) => Tuple2(
                data.notNeeded.length,
                data.notNeeded,
              ),
              builder: (context, data, _) => SizedButton(
                child:
                    Text(LangText.all.local, style: UITexts.mediumButtonText),
                isSelected:
                    data.value2.length == widget.meeting.participants.length,
                onPressed: (isSelected) {
                  if (isSelected) {
                    data.value2.clear();
                  } else {
                    data.value2.addAll(widget.meeting.participants);
                  }
                  context.read<ResponseBuilder>().notify();
                },
              ),
            ),
            ...List.generate(
              widget.meeting.participants.length,
              (index) =>
                  Selector<ResponseBuilder, Tuple2<int, Set<Participant>>>(
                selector: (_, data) => Tuple2(
                  data.notNeeded.length,
                  data.notNeeded,
                ),
                builder: (context, data, _) => SizedButton(
                  child: Text(LangText.n.local, style: UITexts.bigButtonText),
                  isSelected: data.value2.contains(
                    widget.meeting.participants[index],
                  ),
                  onPressed: (isSelected) {
                    if (isSelected) {
                      data.value2.remove(widget.meeting.participants[index]);
                    } else {
                      data.value2.add(widget.meeting.participants[index]);
                    }
                    context.read<ResponseBuilder>().notify();
                  },
                ),
              ),
            ),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 120.0,
              height: 40.0,
              child: Center(
                child: Text(
                  LangText.notPrepared.local,
                  style: UITexts.mediumText,
                ),
              ),
            ),
            Selector<ResponseBuilder, Tuple2<int, Set<Participant>>>(
              selector: (_, data) => Tuple2(
                data.notPrepared.length,
                data.notPrepared,
              ),
              builder: (context, data, _) => SizedButton(
                child: Text(
                  LangText.all.local,
                  style: UITexts.mediumButtonText,
                ),
                isSelected:
                    data.value2.length == widget.meeting.participants.length,
                onPressed: (isSelected) {
                  if (isSelected) {
                    data.value2.clear();
                  } else {
                    data.value2.addAll(widget.meeting.participants);
                  }
                  context.read<ResponseBuilder>().notify();
                },
              ),
            ),
            ...List.generate(
              widget.meeting.participants.length,
              (index) =>
                  Selector<ResponseBuilder, Tuple2<int, Set<Participant>>>(
                selector: (_, data) => Tuple2(
                  data.notPrepared.length,
                  data.notPrepared,
                ),
                builder: (context, data, _) => SizedButton(
                  child: Text(LangText.p.local, style: UITexts.bigButtonText),
                  isSelected: data.value2.contains(
                    widget.meeting.participants[index],
                  ),
                  onPressed: (isSelected) {
                    if (isSelected) {
                      data.value2.remove(widget.meeting.participants[index]);
                    } else {
                      data.value2.add(widget.meeting.participants[index]);
                    }
                    context.read<ResponseBuilder>().notify();
                  },
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 40.0,
                child: Center(
                  child: Text('participant', style: UITexts.sectionSubheader),
                ),
              ),
              const SizedBox(height: 64.0),
              ...List.generate(
                widget.meeting.participants.length,
                (index) => SizedBox(
                  height: 64.0,
                  child: Center(
                    child: Text(
                      widget.meeting.participants[index].fullName,
                      style: UITexts.mediumText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getLang(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final ppl = widget.meeting.painPoints.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting.title),
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
        create: (_) => ResponseBuilder(),
        builder: (context, _) => Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Column()),
              Expanded(
                flex: 3,
                child: ListView(
                  children: [
                    Selector<ResponseBuilder, double>(
                      selector: (_, data) => data.quality,
                      builder: (context, quality, _) => Column(children: [
                        Text(
                          'Rate the meeting quality',
                          style: UITexts.sectionSubheader,
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 16.0,
                            trackShape: const RoundedRectSliderTrackShape(),
                            thumbShape: PolygonSliderThumb(
                              thumbRadius: 16.0,
                              sliderValue: quality,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 32.0,
                            ),
                          ),
                          child: Slider(
                            value: quality,
                            activeColor: Color.alphaBlend(
                              Colors.red
                                  .withAlpha((255 - quality * 255).toInt()),
                              Colors.green.withAlpha((quality * 255).toInt()),
                            ),
                            min: 0,
                            max: 1,
                            divisions: null,
                            onChanged: (value) {
                              context.read<ResponseBuilder>().quality = value;
                            },
                          ),
                        ),
                      ]),
                    ),
                    participantSelectionBuilder(context),
                    const SizedBox(height: 12.0),
                    SizedBox(
                      height: min(widget.meeting.painPoints.length, 2) *
                          max(
                            125.0,
                            MediaQuery.of(context).size.height * 0.18,
                          ),
                      child: Center(
                        child: GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: List.generate(
                            widget.meeting.painPoints.length,
                            (index) {
                              return Selector<ResponseBuilder,
                                  Tuple2<int, Map<String, String>>>(
                                selector: (_, data) => Tuple2(
                                  data.painPoints.length,
                                  data.painPoints,
                                ),
                                builder: (context, data, _) => SizedButton(
                                  child: Text(
                                      widget.meeting.painPoints[ppl[index]]!),
                                  isSelected:
                                      data.value2.containsKey(ppl[index]),
                                  onPressed: (isSelected) {
                                    if (isSelected) {
                                      data.value2.remove(ppl[index]);
                                    } else {
                                      data.value2[ppl[index]] = widget
                                          .meeting.painPoints[ppl[index]]!;
                                    }
                                    context.read<ResponseBuilder>().notify();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Additional comments',
                      ),
                      controller: _controller,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedButton(
                      height: null,
                      width: null,
                      padding: const EdgeInsets.all(24.0),
                      onPressed: (_) {
                        submitReview(context);
                        Navigator.of(context).pop();
                      },
                      isSelected: true,
                      child: Text(
                        'Submit review',
                        style: UITexts.bigButtonText,
                      ),
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

  void submitReview(BuildContext context) {
    context.read<ResponseBuilder>().participant = widget.participant;
    context.read<ResponseBuilder>().feedback = _controller.text;
    // List<Participant> redundant = [];
    // _participants.asMap().forEach((index, participant) {
    //   if (_selectedRedundant[index]) {
    //     redundant.add(participant);
    //   }
    // });

    // List<Participant> unprepared = [];
    // _participants.asMap().forEach((index, participant) {
    //   if (_selectedUnprepared[index]) {
    //     unprepared.add(participant);
    //   }
    // });

    // Map<String, String> selectedPainPoints = {};
    // painPoints.forEach((index, text) {
    //   if (_selectedPainPoints[index]) {
    //     selectedPainPoints[index] = text;
    //   }
    // });

    Participant participant = widget.participant;

    Response response = context.read<ResponseBuilder>().build();

    postReviewOnBackend(response);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review saved: ${response.toJson()}')),
    );
  }
}

class PolygonSliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final double sliderValue;

  const PolygonSliderThumb({
    required this.thumbRadius,
    required this.sliderValue,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    int sides = 4;
    double innerPolygonRadius = thumbRadius * 1.2;
    double outerPolygonRadius = thumbRadius * 1.4;
    double angle = (pi * 2) / sides;

    final outerPathColor = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;

    var outerPath = Path();

    Offset startPoint2 = Offset(
      outerPolygonRadius * cos(0.0),
      outerPolygonRadius * sin(0.0),
    );

    outerPath.moveTo(
      startPoint2.dx + center.dx,
      startPoint2.dy + center.dy,
    );

    for (int i = 1; i <= sides; i++) {
      double x = outerPolygonRadius * cos(angle * i) + center.dx;
      double y = outerPolygonRadius * sin(angle * i) + center.dy;
      outerPath.lineTo(x, y);
    }

    outerPath.close();
    canvas.drawPath(outerPath, outerPathColor);

    final innerPathColor = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.black
      ..style = PaintingStyle.fill;

    var innerPath = Path();

    Offset startPoint = Offset(
      innerPolygonRadius * cos(0.0),
      innerPolygonRadius * sin(0.0),
    );

    innerPath.moveTo(
      startPoint.dx + center.dx,
      startPoint.dy + center.dy,
    );

    for (int i = 1; i <= sides; i++) {
      double x = innerPolygonRadius * cos(angle * i) + center.dx;
      double y = innerPolygonRadius * sin(angle * i) + center.dy;
      innerPath.lineTo(x, y);
    }

    innerPath.close();
    canvas.drawPath(innerPath, innerPathColor);
  }
}
