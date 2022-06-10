import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/browser_client.dart';
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

/// The global [http.Client].
final _httpClient = BrowserClient()
// ..withCredentials = true
    ;

/// The headers for API requests.
final _headers = {
  'accept': 'application/json',
  'content-type': 'application/json',
};

// GET

/// Get the list of [Meeting]s.
Future<List<Meeting>> getMeetings() async {
  // if (testMode) {
  //   return Future.delayed(const Duration(seconds: 1), () => [testMeeting]);
  // }
  http.Response response = await _httpClient.get(Uri.parse(API.getDashboard()));
  var jsonList = (jsonDecode(response.body)
      as Map<String, dynamic>)[Fields.meetings] as List<dynamic>;
  return jsonList.map((e) => Meeting.fromJson(Meeting.flatten(e))).toList();
}

/// Get the full content of one [Meeting] based on its id.
Future<Meeting?> getMeetingContent(String meetingId) async {
  // if (testMode) {
  //   return Future(() => testMeeting2);
  // }

  final meetingResponse = json.decode((await http.get(
    Uri.parse(API.meeting(meetingId)),
  ))
      .body);

  if (meetingResponse == null) {
    // Go to summary
    return null;
  }

  final response = Meeting.flatten(meetingResponse as Map<String, dynamic>);
  response[Fields.meetingId] = meetingId;
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
  // if (testMode) {
  //   return Future(() => testParticipants);
  // }
  final foo = (await http.get(Uri.parse(API.getParticipants())));
  Map<String, dynamic> bar = json.decode(foo.body);
  List<dynamic> jsonList = bar["participants"];
  return jsonList.map((e) => Participant.fromJson(e)).toList();
}

Future<List<Response>> getMeetingSummary(Meeting meeting,
    {String? uuid}) async {
  if (testMode || true) {
    return Future(() => testResponses);
  }
  // TODO: Back-end for this DNE yet
  dynamic jsonList =
      json.decode((await http.get(Uri.parse(API.meetingReviews()))).body);
  print(jsonList);
  return jsonList.map((e) => Response.fromJson(e)).toList();
}

// POST

/// Create a new meeting.
Future<bool> postNewMeetingOnBackend(Meeting meeting) async {
  try {
    final foo = meeting.toJson();
    foo['meeting'] = {
      'title': foo['title'],
      'start_time': foo['start_time'],
      'end_time': foo['end_time'],
    };
    foo[Fields.participants] = (foo[Fields.participants] as List<dynamic>)
        .map((e) => (e as Map<String, dynamic>)[Fields.participantId])
        .toList();
    print(json.encode(foo));
    final response = await http.post(
      Uri.parse(API.postMeeting()),
      headers: _headers,
      body: json.encode(foo),
    );
    print(response.body);
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

/// Sign the user up. Returns non-empty error [String] if there is an error.
Future<String> postSignUpCredentialsToBackend(
    LoginCredentials loginCredentials, User user) async {
  http.Response response = await http.post(
    Uri.parse(API.postSignUp()),
    body: json.encode(loginCredentials.toJson()),
  );

  final String? errMsg =
      ((json.decode(response.body) as Map<String, dynamic>?) ?? {})['message'];
  return errMsg ?? "";
}

Future<void> postLoginCredentialsToBackend(
    LoginCredentials loginCredentials, User user) async {
  if (!testMode) {
    http.Response response = await _httpClient.post(
      Uri.parse(API.postLogin()),
      body: json.encode(loginCredentials.toJson()),
    );
  }
}

/// Post the review to the database.
void postReviewOnBackend(String meetingId, Response review) async {
  final json = review.toJson();
  json[Fields.painPoints] =
      (json[Fields.painPoints] as Map<String, String>).keys.toList();
  json[Fields.notNeeded] =
      (json[Fields.notNeeded] as List<Map<String, dynamic>>)
          .map((e) => e[Fields.participantId])
          .toList();
  json[Fields.notPrepared] =
      (json[Fields.notPrepared] as List<Map<String, dynamic>>)
          .map((e) => e[Fields.participantId])
          .toList();
  http.Response response = await http.post(
    Uri.parse(API.meeting(meetingId)),
    headers: _headers,
    body: jsonEncode(json),
  );
  // print(response.body);
}
