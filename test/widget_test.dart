import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rivia/models/response.dart';
import 'package:rivia/utilities/http_requests.dart';

List<Participant> testParticipants = [
  Participant(name: "Mamezuku", surname: "Rai", email: "js@rt.cr"),
  Participant(name: "Giorno", surname: "Giovanna", email: "js@kc.tt"),
];

Meeting testMeeting = Meeting(
  title: "Foo Meeting",
  startTime: DateTime.now(),
  endTime: DateTime.now(),
  participants: List.of(testParticipants),
  painPoints: {'0': "PAINTOS"},
);

Response testResponse = Response(
  participant: testParticipants[0],
  quality: 114.514,
  painPoints: {'0': "PAINTOS"},
  notNeeded: List.of(testParticipants),
  notPrepared: List.of(testParticipants),
  feedback: "HOT PASSION 暑く強い思い",
);

void main() async {
  test('Can encode Meeting', () {
    final jason = json.encode(testMeeting.toJson());
    debugPrint(jason);
    debugPrint(Meeting.fromJson(json.decode(jason)).toString());
  });

  test('Can encode Response', () {
    final jason = json.encode(testResponse.toJson());
    debugPrint(jason);
    debugPrint(Response.fromJson(json.decode(jason)).toString());
  });

  test('Can GET list of Meetings', () async {
    final meetings = await getMeetings();
    debugPrint("Meetings successfully fetched:");
    for (var meeting in meetings) {
      debugPrint(json.encode(meeting.toJson()));
    }
  });

  test('Can GET list of Participants', () async {
    final participants = await getOrganisationParticipants();
    debugPrint("participants successfully fetched:");
    for (var participant in participants) {
      debugPrint(json.encode(participant.toJson()));
    }
  });

  // testWidgets('Can encode Meeting', (WidgetTester tester) async {
  //   final j1 = json.encode(testMeeting.toJson());
  //   print(j1);
  //   print(Meeting.fromJson(json.decode(j1)));
  //   // // Build our app and trigger a frame.
  //   // await tester.pumpWidget(const MyApp());

  //   // // Verify that our counter starts at 0.
  //   // expect(find.text('0'), findsOneWidget);
  //   // expect(find.text('1'), findsNothing);

  //   // // Tap the '+' icon and trigger a frame.
  //   // await tester.tap(find.byIcon(Icons.add));
  //   // await tester.pump();

  //   // // Verify that our counter has incremented.
  //   // expect(find.text('0'), findsNothing);
  //   // expect(find.text('1'), findsOneWidget);
  // });
}
