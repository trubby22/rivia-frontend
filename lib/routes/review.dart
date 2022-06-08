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
                  child: Text(
                    LangText.participants.local,
                    style: UITexts.sectionSubheader,
                  ),
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
          padding: const EdgeInsets.symmetric(vertical: 24.0),
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
                          LangText.rateQuality.local,
                          style: UITexts.sectionSubheader,
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 16.0,
                            trackShape: const BiColourSliderTrackShape(),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 16.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 32.0,
                            ),
                          ),
                          child: Slider(
                            value: quality,
                            activeColor: Colors.grey,
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
                      decoration: InputDecoration(
                        filled: true,
                        labelText: LangText.additionalComments.local,
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
                        LangText.submitReview.local,
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

    Response response = context.read<ResponseBuilder>().build();

    postReviewOnBackend(response);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review saved: ${response.toJson()}')),
    );
  }
}

class BiColourSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const BiColourSliderTrackShape({
    this.gradient = const LinearGradient(
      colors: [
        Colors.red,
        Colors.yellow,
      ],
    ),
    this.darkenInactive = true,
  });

  final LinearGradient gradient;
  final bool darkenInactive;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 2,
  }) {
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Assign the track segment paints, which are leading: active and
    // trailing: inactive.
    final ColorTween activeTrackColorTween = ColorTween(
        begin: sliderTheme.disabledActiveTrackColor,
        end: sliderTheme.activeTrackColor);
    final ColorTween inactiveTrackColorTween = darkenInactive
        ? ColorTween(
            begin: sliderTheme.disabledInactiveTrackColor,
            end: sliderTheme.inactiveTrackColor)
        : activeTrackColorTween;
    final Paint redPaint = Paint()..color = Colors.red;
    final Paint greenPaint = Paint()..color = Colors.green;
    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Radius trackRadius = Radius.circular(trackRect.height / 2);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        trackRect.top,
        trackRect.right,
        trackRect.bottom,
        topLeft: trackRadius,
        bottomLeft: trackRadius,
        topRight: trackRadius,
        bottomRight: trackRadius,
      ),
      inactivePaint,
    );

    if ((trackRect.left + trackRect.right) / 2 < thumbCenter.dx) {
      context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          (trackRect.left + trackRect.right) / 2,
          trackRect.top - (additionalActiveTrackHeight / 2),
          thumbCenter.dx,
          trackRect.bottom + (additionalActiveTrackHeight / 2),
        ),
        greenPaint,
      );
    }

    if ((trackRect.left + trackRect.right) / 2 > thumbCenter.dx) {
      context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          thumbCenter.dx,
          trackRect.top - (additionalActiveTrackHeight / 2),
          (trackRect.left + trackRect.right) / 2,
          trackRect.bottom + (additionalActiveTrackHeight / 2),
        ),
        redPaint,
      );
    }
  }
}
