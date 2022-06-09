import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rivia/constants/api_endpoints.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/constants/settings.dart';
import 'package:rivia/constants/test_data.dart';
import 'package:rivia/models/login_credentials.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/utilities/change_notifiers.dart';

// GET

/// Get the list of [Meeting]s.
Future<List<Meeting>> getMeetings() async {
  // if (testMode) {
  //   return Future.delayed(const Duration(seconds: 1), () => [testMeeting]);
  // }
  http.Response response = await http.get(Uri.parse(apiGateway + getDashboard));
  var jsonList = (jsonDecode(response.body)
      as Map<String, dynamic>)[Fields.meetings] as List<dynamic>;
  print(Meeting.flatten(jsonList[0]));
  return jsonList.map((e) => Meeting.fromJson(Meeting.flatten(e))).toList();
}

/// Get the full content of one [Meeting] based on its id.
Future<Meeting> getMeetingContent(String meetingId) async {
  if (testMode) {
    return Future(() => testMeeting2);
  }

  print(apiGateway + getMeeting + '/' + meetingId + getReview);
  final response = Meeting.flatten(
    json.decode(
      (await http.get(
        Uri.parse(apiGateway + getMeeting + '/' + meetingId + getReview),
      ))
          .body,
    ) as Map<String, dynamic>,
  );

  if (response[Fields.meetingId] == null) {
    response[Fields.meetingId] == meetingId;
  } else if (response[Fields.meetingId] != meetingId) {
    debugPrint(
      "The meeting id from the response differs from the provided one! Using the latter.",
    );
    response[Fields.meetingId] == meetingId;
  }

  return Meeting.fromJson(response);
}

Future<List<Participant>> getOrganisationParticipants({String? uuid}) async {
  if (testMode) {
    return Future(() => testParticipants);
  }
  List<Map<String, dynamic>> jsonList =
      (await http.get(Uri.parse(apiGateway + getParticipants)))
          as List<Map<String, dynamic>>;
  return jsonList.map((e) => Participant.fromJson(e)).toList();
}

Future<List<Response>> getMeetingSummary(Meeting meeting,
    {String? uuid}) async {
  if (testMode) {
    return Future(() => testResponses);
  }
  List<Map<String, dynamic>> jsonList =
      (await http.get(Uri.parse(apiGateway + getMeetingReviews)))
          as List<Map<String, dynamic>>;
  return jsonList.map((e) => Response.fromJson(e)).toList();
}

// POST

void postNewMeetingOnBackend(Meeting meeting, {String? uuid}) async {
  if (!testMode) {
    await http.post(
      Uri.parse(apiGateway + postMeeting),
      body: meeting.toJson(),
    );
  }
}

/// Sign the user up. Returns non-empty error [String] if there is an error.
Future<String> postSignUpCredentialsToBackend(
    LoginCredentials loginCredentials, User user) async {
  http.Response response = await http.post(
    Uri.parse(apiGateway + postSignUp),
    body: json.encode(loginCredentials.toJson()),
  );

  final String? errMsg =
      ((json.decode(response.body) as Map<String, dynamic>?) ?? {})['message'];

  return errMsg ?? "";
}

Future<void> postLoginCredentialsToBackend(
    LoginCredentials loginCredentials, User user) async {
  if (!testMode) {
    http.Response response = await http.post(
      Uri.parse(apiGateway + postLogin),
      body: json.encode(loginCredentials.toJson()),
    );
    user.uuid = response.body;
  }
}

/// Post the review to the database.
void postReviewOnBackend(Response review) async {
  if (!testMode) {
    final json = review.toJson();
    json[Fields.painPoints] =
        (json[Fields.painPoints] as Map<String, String>).keys.toList();
    http.Response response = await http.post(
      Uri.parse(apiGateway + postReview),
      body: json,
    );
  }
}
