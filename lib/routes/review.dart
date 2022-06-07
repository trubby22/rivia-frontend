import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rivia/constants/languages.dart';
import 'package:rivia/constants/api_endpoints.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/utilities/sized_button.dart';

import 'package:http/http.dart' as http;

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
                child: Text(LangText.all.local, style: UITexts.bigButtonText),
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
                child: Text(LangText.all.local, style: UITexts.bigButtonText),
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
  Widget build(BuildContext context) {
    final ppl = widget.meeting.painPoints.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting.title),
        actions: [
          ElevatedButton(onPressed: () {}, child: Icon(Icons.flag)),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (_) => ResponseBuilder(),
        builder: (context, _) => Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(child: Column()),
              Expanded(
                flex: 3,
                child: ListView(
                  children: [
                    participantSelectionBuilder(context),
                    SizedBox(
                      height: 500.0,
                      child: GridView.count(
                        crossAxisCount: 2,
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
                            );
                          },
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          submitReview(context);
                          Navigator.of(context).pop();
                        },
                        child: Text('Submit review')),
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

  void postReviewOnBackend(Response response) {
    http.post(
      Uri.parse(apiGateway + postReview),
      body: response.toJson(),
    );
  }
}
