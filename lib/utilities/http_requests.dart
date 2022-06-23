import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rivia/utilities/change_notifiers.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;
import 'package:rivia/constants/api_endpoints.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';

/// The global [http.Client].
final _httpClient = BrowserClient();

/// The headers for API requests.
final _headers = {
  'accept': 'application/json',
  'content-type': 'application/json',
};

Future<void> foo(String code) async {
  http.Response response = await _httpClient.post(
    Uri.parse(API.foo()),
    headers: _headers,
    body: json.encode({'authorizationCode': code}),
  );
  final Map<String, dynamic> r = json.decode(response.body)[Fields.jsonData];
  authToken.tenantId = r['tenantId'];
  authToken.userId = r['userId'];
  await setSharedPref();
}

/// Get the [WebSocketChannel], initialise it if necessary.
WebSocketChannel getWebSocket() {
  WebSocketChannel _webSocket;

  _webSocket = WebSocketChannel.connect(
    Uri.parse('wss://websocket.api.rivia.me'),
  );

  _webSocket.sink.add(
    '{"user": "${authToken.userId}", "tenant": "${authToken.tenantId}"}',
  );

  return _webSocket;
}

void disposeWebSocket(WebSocketChannel? _webSocket) {
  _webSocket?.sink.close();
}

// GET

// Get the list of Preset Questions.
Future<Set<String>> getPresets() async {
  http.Response response = await _httpClient.get(Uri.parse(API.getPresets()));
  return (json.decode(response.body)[Fields.jsonData] as List<dynamic>)
      .map(
        (e) {
          final entry = e as Map<String, dynamic>;
          return entry['text'];
        },
      )
      .toSet()
      .cast<String>();
}

Future<void> postPresets(List<String>? presets) async {
  http.Response response = await _httpClient.post(
    Uri.parse(API.postPresets()),
    headers: _headers,
    body: json.encode({
      if (presets != null) Fields.painPoints: presets,
    }),
  );
}

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
  final meetingResponse = (json.decode(
    ((await http.get(Uri.parse(API.getMeeting(meetingId)))).body),
  ))[Fields.jsonData];

  if (meetingResponse == null) {
    // Go to summary
    return null;
  }

  final response = meetingResponse as Map<String, dynamic>;
  if (response[Fields.meetingId] == null) {
    response[Fields.meetingId] = meetingId;
  } else if (response[Fields.meetingId] != meetingId) {
    debugPrint(
      "The meeting id from the response differs from the provided one! Using the latter.",
    );
    response[Fields.meetingId] = meetingId;
  }

  return Meeting.fromJson(response);
}

Future<List<Participant>> getOrganisationParticipants({String? uuid}) async {
  final foo = (await http.get(Uri.parse(API.getParticipants())));
  Map<String, dynamic> bar = json.decode(foo.body);
  List<dynamic> jsonList = bar[Fields.participants];
  return jsonList.map((e) => Participant.fromJson(e)).toList();
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
    final response = await http.post(
      Uri.parse(API.postMeeting()),
      headers: _headers,
      body: json.encode(jason),
    );
    return true;
  } catch (e) {
    debugPrint(e.toString());
    return false;
  }
}

/// See if the current user has reviewed this meeting.
Future<bool> getIsReviewed(String meetingId) async {
  http.Response response = await _httpClient.get(
    Uri.parse(API.getIsReviewed(meetingId)),
    headers: _headers,
  );

  final jason = json.decode(response.body);

  if (jason[Fields.errorCode] != null && jason[Fields.errorCode] != 200) {
    return Future.error(
      "Get isReviewed Failed!\nError Code: ${jason[Fields.errorCode]}",
    );
  }

  return jason[Fields.jsonData];
}

/// Post the review to the database.
void postReview(String meetingId, Response review) async {
  final json = review.toJson();
  json[Fields.painPoints] =
      (json[Fields.painPoints] as Map<String, String>).keys.toList();
  json[Fields.notNeeded] =
      (json[Fields.notNeeded] as List<Map<String, dynamic>>)
          .map((e) => e[Fields.id])
          .toList();
  json[Fields.notPrepared] =
      (json[Fields.notPrepared] as List<Map<String, dynamic>>)
          .map((e) => e[Fields.id])
          .toList();
  json[Fields.needed] = (json[Fields.needed] as List<Map<String, dynamic>>)
      .map((e) => e[Fields.id])
      .toList();
  json[Fields.prepared] = (json[Fields.prepared] as List<Map<String, dynamic>>)
      .map((e) => e[Fields.id])
      .toList();
  http.Response response = await http.post(
    Uri.parse(API.getReview(meetingId)),
    headers: _headers,
    body: jsonEncode(json),
  );
}

Future<void> postTiming(List<double> times) async {
  http.Response response = await _httpClient.post(
    Uri.parse(API.timing()),
    headers: _headers,
    body: json.encode({'timings': times}),
  );
}

Future<void> postRating(double use, double like) async {
  http.Response response = await _httpClient.post(
    Uri.parse(API.rating()),
    headers: _headers,
    body: json.encode({'use': use, 'like': like}),
  );
}
