import 'dart:async';
import 'dart:math';

import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/routes/redirect.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:rivia/utilities/http_requests.dart';
import 'package:rivia/utilities/language_switcher.dart';
import 'package:rivia/utilities/log_out_button.dart';
import 'package:rivia/utilities/sized_button.dart';
import 'package:rivia/utilities/toast.dart';

enum ReviewSteps {
  slider,
  selection,
  feedback,
  rating,
}

class Review extends StatefulWidget {
  final Meeting meeting;
  final Participant? participant;

  const Review({
    Key? key,
    required this.meeting,
    this.participant,
  }) : super(key: key);

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final TextEditingController _controller = TextEditingController();
  ReviewSteps _step = ReviewSteps.slider;
  double x1 = 0.5;
  double x2 = 0.5;
  bool submitted = false;
  int p1 = 0;
  int p2 = 0;
  int p3 = 0;
  Timer? periodicTimer;

  /// Build the selection panel.
  Widget selectionPanelBuilder(
    BuildContext context, {
    required String title,
    required Tuple4<int, int, Set<Participant>, Set<Participant>> Function(
      BuildContext,
      ResponseBuilder,
    )
        selector,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120.0,
          height: 40.0,
          child: Center(
            child: Text(title, style: UITexts.bigText),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            children: [
              ...List.generate(
                widget.meeting.participants.length,
                (index) => Selector<ResponseBuilder,
                    Tuple4<int, int, Set<Participant>, Set<Participant>>>(
                  selector: selector,
                  builder: (context, data, _) => Row(
                    children: [
                      SizedButton(
                        padding: EdgeInsets.zero,
                        useShadow: false,
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                        primaryColour: Colors.green,
                        onPressedColour: Colors.green.shade300,
                        radius: BorderRadius.only(
                          topLeft: Radius.circular(index == 0 ? 16.0 : 0.0),
                          bottomLeft: Radius.circular(
                            index == widget.meeting.participants.length - 1
                                ? 16.0
                                : 0.0,
                          ),
                        ),
                        child: Text(
                          LangText.yes.local,
                          style: UITexts.mediumButtonText,
                        ),
                        isSelected: data.value3.contains(
                          widget.meeting.participants[index].participant,
                        ),
                        onPressed: (isSelected) {
                          final participant =
                              widget.meeting.participants[index].participant;
                          if (isSelected) {
                            data.value3.remove(participant);
                          } else {
                            data.value4.remove(participant);
                            data.value3.add(participant);
                          }
                          context.read<ResponseBuilder>().notify();
                        },
                      ),
                      SizedButton(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 0.5,
                        ),
                        primaryColour: Colors.red,
                        onPressedColour: Colors.red.shade300,
                        radius: BorderRadius.only(
                          topRight: Radius.circular(index == 0 ? 16.0 : 0.0),
                          bottomRight: Radius.circular(
                            index == widget.meeting.participants.length - 1
                                ? 16.0
                                : 0.0,
                          ),
                        ),
                        useShadow: false,
                        child: Text(
                          LangText.no.local,
                          style: UITexts.mediumButtonText,
                        ),
                        isSelected: data.value4.contains(
                          widget.meeting.participants[index].participant,
                        ),
                        onPressed: (isSelected) {
                          final participant =
                              widget.meeting.participants[index].participant;
                          if (isSelected) {
                            data.value4.remove(participant);
                          } else {
                            data.value3.remove(participant);
                            data.value4.add(participant);
                          }
                          context.read<ResponseBuilder>().notify();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the checkboxes that vote each participant needed or prepared.
  Widget participantSelectionBuilder(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        selectionPanelBuilder(
          context,
          title: LangText.needed.local,
          selector: (_, data) => Tuple4(
            data.needed.length,
            data.notNeeded.length,
            data.needed,
            data.notNeeded,
          ),
        ),
        SizedBox(width: width * 0.04),
        selectionPanelBuilder(
          context,
          title: LangText.prepared.local,
          selector: (_, data) => Tuple4(
            data.prepared.length,
            data.notPrepared.length,
            data.prepared,
            data.notPrepared,
          ),
        ),
        SizedBox(width: width * 0.07),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40.0),
            ...List.generate(
              widget.meeting.participants.length,
              (index) => SizedBox(
                height: 52.0,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.meeting.participants[index].participant.fullName,
                    style: UITexts.bigText,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget mainPageBuilder(BuildContext context) {
    final ppl = widget.meeting.painPoints.keys.toList();
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    switch (_step) {
      case ReviewSteps.slider:
        return Column(
          children: [
            Selector<ResponseBuilder, double>(
              selector: (_, data) => data.quality,
              builder: (context, quality, _) => Column(
                children: [
                  SizedBox(height: height * 0.02),
                  Text(
                    '${widget.meeting.title} '
                    '${TimeOfDay.fromDateTime(widget.meeting.startTime).format(context)} - '
                    '${TimeOfDay.fromDateTime(widget.meeting.endTime).format(context)} '
                    '${widget.meeting.startTime.day}/${widget.meeting.startTime.month}/${widget.meeting.startTime.year}',
                    style: UITexts.sectionHeader,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100.0,
                        child: Text(
                          LangText.bad.local,
                          textAlign: TextAlign.center,
                          style: UITexts.sectionHeader.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            inactiveTrackColor: Colors.white,
                            trackHeight: 32.0,
                            tickMarkShape: const RoundSliderTickMarkShape(
                              tickMarkRadius: 0,
                            ),
                            trackShape: const BiColourSliderTrackShape(),
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 32.0,
                              elevation: 6.0,
                              pressedElevation: 2.0,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 40.0,
                            ),
                          ),
                          child: Slider(
                            value: quality,
                            activeColor: Colors.grey.shade500,
                            min: 0,
                            max: 1,
                            divisions: 6,
                            onChanged: (value) {
                              context.read<ResponseBuilder>().quality = value;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100.0,
                        child: Text(
                          LangText.good.local,
                          textAlign: TextAlign.center,
                          style: UITexts.sectionHeader.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12.0),
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: const [
                  BoxShadow(offset: Offset(0, 0.5), blurRadius: 1.0),
                ],
              ),
              width: width * 0.7,
              child: Column(
                children: List.generate(
                  widget.meeting.painPoints.length,
                  (index) {
                    return Selector<ResponseBuilder,
                        Tuple2<int, Map<String, String>>>(
                      selector: (_, data) => Tuple2(
                        data.painPoints.length,
                        data.painPoints,
                      ),
                      builder: (context, data, _) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12.0,
                        ),
                        child: SizedButton(
                          primaryColour: Colors.black,
                          selectedColour: Colors.white,
                          onPressedColour: Colors.blue,
                          backgroundColour: Colors.blue.shade100,
                          width: width * 0.3,
                          height: 52.0,
                          radius: BorderRadius.circular(20.0),
                          child: Text(
                            widget.meeting.painPoints[ppl[index]]!,
                            textAlign: TextAlign.center,
                            style: UITexts.mediumButtonText.copyWith(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          useShadow: !data.value2.containsKey(ppl[index]),
                          isSelected: data.value2.containsKey(ppl[index]),
                          onPressed: (isSelected) {
                            if (isSelected) {
                              data.value2.remove(ppl[index]);
                            } else {
                              data.value2[ppl[index]] =
                                  widget.meeting.painPoints[ppl[index]]!;
                            }
                            context.read<ResponseBuilder>().notify();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 48.0,
                  width: width * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: Colors.grey.shade600),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: width * 0.2 / 3.0,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(style: BorderStyle.none),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.04),
                Consumer<ResponseBuilder>(
                  builder: (context, data, _) => SizedButton(
                    onPressedColour: Colors.grey.shade500,
                    height: null,
                    width: width * 0.12,
                    radius: BorderRadius.circular(24.0),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    onPressed: (_) {
                      data.quality = 0.5;
                      data.painPoints.clear();
                      setState(() => _step = ReviewSteps.selection);
                    },
                    isSelected: true,
                    child: Text(
                      LangText.skip.local,
                      style: UITexts.bigButtonText,
                    ),
                  ),
                ),
                SizedBox(width: width * 0.02),
                SizedButton(
                  height: null,
                  width: width * 0.12,
                  radius: BorderRadius.circular(24.0),
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  onPressed: (_) {
                    setState(() => _step = ReviewSteps.selection);
                  },
                  isSelected: true,
                  child: Text(
                    LangText.next.local,
                    style: UITexts.bigButtonText,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
          ],
        );
      case ReviewSteps.selection:
        return Column(
          children: [
            SizedBox(height: height * 0.02),
            Text(
              '${widget.meeting.title} '
              '${TimeOfDay.fromDateTime(widget.meeting.startTime).format(context)} - '
              '${TimeOfDay.fromDateTime(widget.meeting.endTime).format(context)} '
              '${widget.meeting.startTime.day}/${widget.meeting.startTime.month}/${widget.meeting.startTime.year}',
              style: UITexts.sectionHeader,
            ),
            SizedBox(height: height * 0.04),
            SizedBox(
              width: width * 0.7,
              child: participantSelectionBuilder(context),
            ),
            SizedBox(height: height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 48.0,
                  width: width * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: Colors.grey.shade600),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: width * 0.4 / 3.0,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(24.0),
                        border: Border.all(style: BorderStyle.none),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: width * 0.04),
                Consumer<ResponseBuilder>(
                  builder: (context, data, _) => SizedButton(
                    onPressedColour: Colors.grey.shade500,
                    height: null,
                    width: width * 0.12,
                    radius: BorderRadius.circular(24.0),
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    onPressed: (_) {
                      data.needed.clear();
                      data.prepared.clear();
                      data.notNeeded.clear();
                      data.notPrepared.clear();
                      setState(() => _step = ReviewSteps.feedback);
                    },
                    isSelected: true,
                    child: Text(
                      LangText.skip.local,
                      style: UITexts.bigButtonText,
                    ),
                  ),
                ),
                SizedBox(width: width * 0.02),
                SizedButton(
                  height: null,
                  width: width * 0.12,
                  radius: BorderRadius.circular(24.0),
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  onPressed: (_) {
                    setState(() => _step = ReviewSteps.feedback);
                  },
                  isSelected: true,
                  child: Text(
                    LangText.next.local,
                    style: UITexts.bigButtonText,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
          ],
        );
      case ReviewSteps.feedback:
        return Column(
          children: [
            SizedBox(height: height * 0.02),
            Text(
              '${widget.meeting.title} '
              '${TimeOfDay.fromDateTime(widget.meeting.startTime).format(context)} - '
              '${TimeOfDay.fromDateTime(widget.meeting.endTime).format(context)} '
              '${widget.meeting.startTime.day}/${widget.meeting.startTime.month}/${widget.meeting.startTime.year}',
              style: UITexts.sectionHeader,
            ),
            SizedBox(height: height * 0.04),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0.5),
                    blurRadius: 1.0,
                  ),
                ],
              ),
              child: TextField(
                minLines: 10,
                maxLines: null,
                style: UITexts.bigText,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(20.0),
                  fillColor: Colors.white,
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightBlue),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                  ),
                  filled: true,
                  labelText: LangText.additionalComments.local,
                ),
                controller: _controller,
              ),
            ),
            SizedBox(height: height * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 48.0,
                  width: width * 0.2,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: Colors.grey.shade600),
                  ),
                ),
                SizedBox(width: width * 0.13),
                SizedButton(
                  height: null,
                  width: width * 0.17,
                  radius: BorderRadius.circular(24.0),
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  onPressed: (_) {
                    setState(() => _step = ReviewSteps.rating);
                  },
                  isSelected: true,
                  child: Text(
                    LangText.next.local,
                    style: UITexts.bigButtonText,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
          ],
        );
      case ReviewSteps.rating:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: height * 0.02),
            Text(
              'To what extent do you think our product is sueful?',
              style: UITexts.sectionHeader,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100.0,
                  child: Text(
                    LangText.bad.local,
                    textAlign: TextAlign.center,
                    style: UITexts.sectionHeader.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      inactiveTrackColor: Colors.white,
                      trackHeight: 32.0,
                      tickMarkShape: const RoundSliderTickMarkShape(
                        tickMarkRadius: 0,
                      ),
                      trackShape: const BiColourSliderTrackShape(),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 32.0,
                        elevation: 6.0,
                        pressedElevation: 2.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 40.0,
                      ),
                    ),
                    child: Slider(
                      value: x1,
                      activeColor: Colors.grey.shade500,
                      min: 0,
                      max: 1,
                      divisions: 4,
                      onChanged: (value) => setState(() => x1 = value),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100.0,
                  child: Text(
                    LangText.good.local,
                    textAlign: TextAlign.center,
                    style: UITexts.sectionHeader.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),
            Text(
              'How would you rate our product in terms of clarity and easy to use?',
              style: UITexts.sectionHeader,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100.0,
                  child: Text(
                    LangText.bad.local,
                    textAlign: TextAlign.center,
                    style: UITexts.sectionHeader.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      inactiveTrackColor: Colors.white,
                      trackHeight: 32.0,
                      tickMarkShape: const RoundSliderTickMarkShape(
                        tickMarkRadius: 0,
                      ),
                      trackShape: const BiColourSliderTrackShape(),
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 32.0,
                        elevation: 6.0,
                        pressedElevation: 2.0,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 40.0,
                      ),
                    ),
                    child: Slider(
                      value: x2,
                      activeColor: Colors.grey.shade500,
                      min: 0,
                      max: 1,
                      divisions: 4,
                      onChanged: (value) => setState(() => x2 = value),
                    ),
                  ),
                ),
                SizedBox(
                  width: 100.0,
                  child: Text(
                    LangText.good.local,
                    textAlign: TextAlign.center,
                    style: UITexts.sectionHeader.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.03),
            SizedButton(
              height: null,
              width: width * 0.20,
              radius: BorderRadius.circular(24.0),
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              onPressed: (_) async {
                if (!submitted) {
                  submitted = true;
                  print('$p1, $p2, $p3');
                  final review = submitReview(context);
                  final timing = postTiming([
                    p1.toDouble(),
                    p2.toDouble(),
                    p3.toDouble(),
                  ]);
                  final rating = postRating(x1, x2);
                  await Future.wait([review, timing, rating]);
                  // TODO: Explicitly go to analytics instead of mere pop
                  Navigator.of(context).pop();
                }
              },
              isSelected: true,
              child: Text(
                LangText.submit.local,
                style: UITexts.bigButtonText,
              ),
            ),
            SizedBox(height: height * 0.02),
          ],
        );
    }
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
              LangText.confidentialSurvey.local,
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
          child: mainPageBuilder(context),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    getSharedPref(() => setState(() {}));
    periodicTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        switch (_step) {
          case ReviewSteps.slider:
            p1++;
            break;
          case ReviewSteps.selection:
            p2++;
            break;
          case ReviewSteps.feedback:
            p3++;
            break;
          default:
            break;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider(
        create: (_) => ResponseBuilder(),
        builder: (context, _) => Stack(
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
            if (_step != ReviewSteps.rating)
              Positioned(
                left: 64.0,
                top: 24.0,
                child: SizedButton(
                  backgroundColour: const Color.fromRGBO(239, 198, 135, 1),
                  primaryColour: Colors.black,
                  onPressedColour: const Color.fromRGBO(239, 198, 135, 1),
                  height: 48.0,
                  width: 48.0,
                  radius: BorderRadius.circular(24.0),
                  onPressed: (_) {
                    switch (_step) {
                      case ReviewSteps.slider:
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        } else {
                          dashboard(context);
                        }
                        break;
                      case ReviewSteps.selection:
                        setState(() => _step = ReviewSteps.slider);
                        break;
                      case ReviewSteps.feedback:
                        setState(() => _step = ReviewSteps.selection);
                        break;
                      default:
                        break;
                    }
                  },
                  child: const Icon(Icons.arrow_back, size: 32.0),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> submitReview(BuildContext context) async {
    // context.read<ResponseBuilder>().participant = widget.participant;
    context.read<ResponseBuilder>().feedback = _controller.text;

    Response response = context.read<ResponseBuilder>().build();
    showToast(context: context, text: 'Review saved: ${response.toJson()}');
    if (widget.meeting.meetingId == null) {
      debugPrint("Bad meeting: NO ID!");
    } else {
      postReview(widget.meeting.meetingId!, response);
    }
  }
}

class BiColourSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const BiColourSliderTrackShape();

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
    double additionalActiveTrackHeight = 0,
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
    final ColorTween inactiveTrackColorTween = ColorTween(
      begin: sliderTheme.disabledInactiveTrackColor,
      end: sliderTheme.inactiveTrackColor,
    );

    final Paint inactivePaint = Paint()
      ..color = inactiveTrackColorTween.evaluate(enableAnimation)!;

    final Radius trackRadius = Radius.circular(trackRect.height / 2);

    context.canvas.drawRRect(
      RRect.fromLTRBAndCorners(
        trackRect.left,
        trackRect.top + 0.5,
        trackRect.right,
        trackRect.bottom + 0.5,
        topLeft: trackRadius,
        bottomLeft: trackRadius,
        topRight: trackRadius,
        bottomRight: trackRadius,
      ),
      Paint()
        ..color = Colors.black
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.57735 + 0.5),
    );

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
          trackRect.top - (additionalActiveTrackHeight / 2) + 1,
          thumbCenter.dx,
          trackRect.bottom + (additionalActiveTrackHeight / 2) + 1,
        ),
        Paint()
          ..color = Colors.black
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.57735 + 0.5),
      );

      context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          (trackRect.left + trackRect.right) / 2,
          trackRect.top - (additionalActiveTrackHeight / 2),
          thumbCenter.dx,
          trackRect.bottom + (additionalActiveTrackHeight / 2),
        ),
        Paint()..color = Colors.green,
      );
    }

    if ((trackRect.left + trackRect.right) / 2 > thumbCenter.dx) {
      context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          thumbCenter.dx,
          trackRect.top - (additionalActiveTrackHeight / 2) + 1,
          (trackRect.left + trackRect.right) / 2,
          trackRect.bottom + (additionalActiveTrackHeight / 2) + 1,
        ),
        Paint()
          ..color = Colors.black
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.57735 + 0.5),
      );

      context.canvas.drawRRect(
        RRect.fromLTRBAndCorners(
          thumbCenter.dx,
          trackRect.top - (additionalActiveTrackHeight / 2),
          (trackRect.left + trackRect.right) / 2,
          trackRect.bottom + (additionalActiveTrackHeight / 2),
        ),
        Paint()..color = Colors.red,
      );
    }
  }
}
