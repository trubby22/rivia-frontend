// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rivia/models/response.dart';

List<Participant> testParticipants = [
  Participant(name: "Jacen", surname: "Solo", email: "js@rt.cr"),
  Participant(name: "Luke", surname: "Skywalker", email: "js@kc.tt"),
];

Meeting testMeeting = Meeting(
  title: "Foo Meeting",
  startTime: DateTime.now(),
  endTime: DateTime.now(),
  participants: List.of(testParticipants),
);

Response testResponse = Response(
  participant: testParticipants[0],
  quality: 114.514,
  painPoints: {0: "PAINTOS"},
  notNeeded: List.of(testParticipants),
  notPrepared: List.of(testParticipants),
  feedback: "HOT PASSION 暑く強い思い",
);

void main() {
  testWidgets('Can encode Meeting', (WidgetTester tester) async {
    final jason = json.encode(testMeeting.toJson());
    print(jason);
    print(Meeting.fromJson(json.decode(jason)));
  });

  testWidgets('Can encode Response', (WidgetTester tester) async {
    final jason = json.encode(testResponse.toJson());
    print(jason);
    print(Response.fromJson(json.decode(jason)));
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
