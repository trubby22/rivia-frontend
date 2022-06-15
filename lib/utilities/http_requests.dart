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
final _httpClient = BrowserClient();

/// The headers for API requests.
final _headers = {
  'accept': 'application/json',
  'content-type': 'application/json',
};

// GET

/// Get the list of [Meeting]s.
Future<List<String>> getMeetings() async {
  http.Response response = await _httpClient.get(Uri.parse(API.getMeetings()));

  final jason = jsonDecode(response.body);

  if (jason[Fields.errorCode] != null && jason[Fields.errorCode] != 200) {
    return Future.error(
      "Get Meetings Failed!\nError Code: ${jason[Fields.errorCode]}",
    );
  }

  var jsonList = (jason[Fields.jsonData] as List<dynamic>).cast<String>();
  return jsonList;
}

/// Get the full content of one [Meeting] based on its id.
Future<Meeting?> getMeetingContent(String meetingId) async {
  print((API.getMeeting(meetingId)));
  final meetingResponse = (json.decode(
    ((await http.get(Uri.parse(API.getMeeting(meetingId)))).body),
  ))[Fields.jsonData];

  print('response: $meetingResponse');

  if (meetingResponse == null) {
    // Go to summary
    return null;
  }

  final response = meetingResponse as Map<String, dynamic>;
  if (response[Fields.meetingId] == null) {
    response[Fields.meetingId] == meetingId;
  } else if (response[Fields.meetingId] != meetingId) {
    debugPrint(
      "The meeting id from the response differs from the provided one! Using the latter.",
    );
    response[Fields.meetingId] == meetingId;
  }

  print('edited response: $meetingResponse');
  print('from JSON: ${Meeting.fromJson(response)}');

  return Meeting.fromJson(response);
}

Future<List<Participant>> getOrganisationParticipants({String? uuid}) async {
  final foo = (await http.get(Uri.parse(API.getParticipants())));
  Map<String, dynamic> bar = json.decode(foo.body);
  List<dynamic> jsonList = bar[Fields.participants];
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
Future<bool> postMeeting(Meeting meeting) async {
  try {
    final organiser = meeting.participants.firstWhere(
      (e) => e.participant.id == 'seven',
    );
    meeting.participants.remove(organiser);
    final jason = meeting.toJson();
    jason[Fields.participants] = (jason[Fields.participants] as List<dynamic>)
        .map((p) => p[Fields.participant])
        .toList();

    jason['organizer'] = {
      'name': organiser.participant.name,
      'surname': organiser.participant.surname,
    };
    print("JSON: $jason");
    print("STR: ${json.encode(jason)}");
    final response = await http.post(
      Uri.parse(API.postMeeting()),
      headers: _headers,
      body: json.encode(jason),
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
  LoginCredentials loginCredentials,
) async {
  http.Response response = await http.post(
    Uri.parse(API.postSignUp()),
    body: json.encode(loginCredentials.toJson()),
  );

  final String? errMsg =
      ((json.decode(response.body) as Map<String, dynamic>?) ??
          {})[Fields.message];
  return errMsg ?? "";
}

Future<void> postLoginCredentialsToBackend(
  LoginCredentials loginCredentials,
) async {
  if (!testMode) {
    http.Response response = await _httpClient.post(
      Uri.parse(API.postLogin()),
      headers: _headers,
      body: json.encode(loginCredentials.toJson()),
    );
  }
}

/// Post the review to the database.
void postReview(String meetingId, Response review) async {
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
  json[Fields.needed] = (json[Fields.needed] as List<Map<String, dynamic>>)
      .map((e) => e[Fields.participantId])
      .toList();
  json[Fields.prepared] = (json[Fields.prepared] as List<Map<String, dynamic>>)
      .map((e) => e[Fields.participantId])
      .toList();
  print(API.getReview(meetingId));
  print(jsonEncode(json));
  http.Response response = await http.post(
    Uri.parse(API.getReview(meetingId)),
    headers: _headers,
    body: jsonEncode(json),
  );
}
