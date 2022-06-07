import 'package:flutter/material.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/constants/pain_points.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/utilities/sized_button.dart';

class Review extends StatefulWidget {
  final Meeting meeting;
  final Participant participant;

  Review({
    Key? key,
    required this.meeting,
    required this.participant,
  }) : super(key: key);

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  final TextEditingController _controller = TextEditingController();
  late List<Participant> _participants = widget.meeting.participants;
  late List<bool> _selectedRedundant =
      List.generate(_participants.length, (_) => false);
  late List<bool> _selectedUnprepared =
      List.generate(_participants.length, (_) => false);
  // late List<bool> _selectedPainPoints =
  //     List.generate(painPoints.length, (_) => false);
  bool _selectAllRedundant = false;
  bool _selectAllUnprepared = false;
  double _quality = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meeting.title),
        actions: [
          ElevatedButton(onPressed: () {}, child: Icon(Icons.flag)),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: Column()),
            Expanded(
              flex: 3,
              child: ListView(
                children: [
                  Row(
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
                                'Not Needed',
                                style: UITexts.mediumText,
                              ),
                            ),
                          ),
                          const SizedButton(
                            child: Text("ALL"),
                          ),
                          ...List.generate(
                            widget.meeting.participants.length,
                            (_) => const SizedButton(
                              child: Text("N"),
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
                                'Not Prepared',
                                style: UITexts.mediumText,
                              ),
                            ),
                          ),
                          const SizedButton(
                            child: Text("ALL"),
                          ),
                          ...List.generate(
                            widget.meeting.participants.length,
                            (_) => const SizedButton(
                              child: Text("P"),
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
                                  'participant',
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
                  ),
                  SizedBox(
                    height: 500.0,
                    child: GridView.count(
                      crossAxisCount: 2,
                      scrollDirection: Axis.horizontal,
                      children: List.generate(
                        painPoints.length,
                        (index) {
                          return GestureDetector(
                            child: Card(
                              child: Text("painPoints[index]"),
                            ),
                            onTap: () {},
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
                        submitReview();
                        Navigator.of(context).pop();
                      },
                      child: Text('Submit review')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void submitReview() {
    String feedback = _controller.value.text;

    List<Participant> redundant = [];
    _participants.asMap().forEach((index, participant) {
      if (_selectedRedundant[index]) {
        redundant.add(participant);
      }
    });

    List<Participant> unprepared = [];
    _participants.asMap().forEach((index, participant) {
      if (_selectedUnprepared[index]) {
        unprepared.add(participant);
      }
    });

    // Map<String, String> selectedPainPoints = {};
    // painPoints.forEach((index, text) {
    //   if (_selectedPainPoints[index]) {
    //     selectedPainPoints[index] = text;
    //   }
    // });

    Participant participant = widget.participant;

    Response response = Response(
      participant: participant,
      quality: _quality,
      // painPoints: selectedPainPoints,
      notNeeded: redundant,
      notPrepared: unprepared,
      feedback: feedback,
    );

    postReviewOnBackend(response);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Review saved: $response'),
    ));
  }

  void postReviewOnBackend(Response response) {
    //  TODO()
  }
}
