import 'package:flutter/material.dart';
import 'package:rivia/constants/pain_points.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/utilities/stateful_checkbox.dart';

import '../models/meeting.dart';
import '../models/participant.dart';

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
  late List<bool> _selectedPainPoints =
      List.generate(painPoints.length, (_) => false);
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(child: Column()),
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text('not needed')),
                              Expanded(child: Text('unprepared')),
                              Expanded(child: Text('participant')),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(child: Text('select all')),
                                    Expanded(
                                      child: Checkbox(
                                          value: _selectAllRedundant,
                                          onChanged: (_) {
                                            setState(() {
                                              _selectAllRedundant =
                                                  !_selectAllRedundant;
                                              _selectedRedundant =
                                                  _selectedRedundant
                                                      .map((_) =>
                                                          _selectAllRedundant)
                                                      .toList();
                                            });
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(child: Text('select all')),
                                    Expanded(
                                      child: Checkbox(
                                          value: _selectAllUnprepared,
                                          onChanged: (_) {
                                            setState(() {
                                              _selectAllUnprepared =
                                                  !_selectAllUnprepared;
                                              _selectedUnprepared =
                                                  _selectedUnprepared
                                                      .map((_) =>
                                                          _selectAllUnprepared)
                                                      .toList();
                                            });
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...List.generate(
                          _participants.length,
                          (index) {
                            Participant participant = _participants[index];

                            return Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Checkbox(
                                      value: _selectedRedundant[index],
                                      onChanged: (_) {
                                        setState(() {
                                          _selectedRedundant[index] =
                                              !_selectedRedundant[index];
                                        });
                                      }),
                                  Checkbox(
                                      value: _selectedUnprepared[index],
                                      onChanged: (_) {
                                        setState(() {
                                          _selectedUnprepared[index] =
                                              !_selectedUnprepared[index];
                                        });
                                      }),
                                  Text(participant.fullName),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    //     Row(
                    //   children: [
                    //     Expanded(
                    //       child: Row(
                    //         children: [
                    //           Expanded(
                    //             child: Column(
                    //               children: [
                    //                 Expanded(child: Text('redundant')),
                    //                 ...List.generate(
                    //                     meeting.participants.length, (index) {
                    //                   return Expanded(
                    //                     child: Checkbox(
                    //                         value: false, onChanged: (_) {}),
                    //                   );
                    //                 })
                    //               ],
                    //             ),
                    //           ),
                    //           Expanded(
                    //             child: Column(
                    //               children: [
                    //                 Expanded(child: Text('unprepared')),
                    //                 ...List.generate(
                    //                     meeting.participants.length, (index) {
                    //                   return Expanded(
                    //                     child: Checkbox(
                    //                         value: false, onChanged: (_) {}),
                    //                   );
                    //                 })
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     Expanded(
                    //       child: Column(
                    //         children: [
                    //           Expanded(child: Text('participants')),
                    //           ...List.generate(meeting.participants.length,
                    //               (index) {
                    //             Participant participant =
                    //                 meeting.participants[index];
                    //
                    //             return Expanded(
                    //               child: Text(participant.fullName),
                    //             );
                    //           })
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      scrollDirection: Axis.horizontal,
                      children: List.generate(painPoints.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {},
                            child: Text(painPoints[index]),
                          ),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Additional comments',
                      ),
                      controller: _controller,
                    ),
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

    Map<int, String> selectedPainPoints = {};
    painPoints.asMap().forEach((index, text) {
      if (_selectedPainPoints[index]) {
        selectedPainPoints[index] = text;
      }
    });

    Participant participant = widget.participant;

    Response response = Response(
      participant: participant,
      quality: _quality,
      painPoints: selectedPainPoints,
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
