import 'package:http/http.dart' as http;
import 'package:rivia/constants/api_endpoints.dart';
import 'package:rivia/constants/fields.dart';
import 'package:rivia/constants/settings.dart';
import 'package:rivia/constants/test_data.dart';
import 'package:rivia/models/login_credentials.dart';
import 'package:rivia/models/meeting.dart';
import 'package:rivia/models/participant.dart';
import 'package:rivia/models/response.dart';
import 'package:rivia/routes/meeting_summary.dart';
import 'package:rivia/routes/review.dart';

// GET

Future<List<Meeting>> getMeetings() async {
  if (testMode) {
    return Future(() => [testMeeting]);
  }
  List<Map<String, dynamic>> jsonList =
      (await http.get(Uri.parse(apiGateway + getAllMeetings)))
          as List<Map<String, dynamic>>;
  return jsonList.map((e) => Meeting.fromJson(e)).toList();
}

Future<List<Participant>> getOrganisationParticipants() async {
  if (testMode) {
    return Future(() => testParticipants);
  }
  List<Map<String, dynamic>> jsonList =
      (await http.get(Uri.parse(apiGateway + getParticipants)))
          as List<Map<String, dynamic>>;
  return jsonList.map((e) => Participant.fromJson(e)).toList();
}

Future<List<Response>> getMeetingSummary(Meeting meeting) async {
  if (testMode) {
    return Future(() => testResponses);
  }
  List<Map<String, dynamic>> jsonList =
      (await http.get(Uri.parse(apiGateway + getMeetingReviews)))
          as List<Map<String, dynamic>>;
  return jsonList.map((e) => Response.fromJson(e)).toList();
}

// POST

void postNewMeetingOnBackend(Meeting meeting) {
  if (!testMode) {
    http.post(
      Uri.parse(apiGateway + postMeeting),
      body: meeting.toJson(),
    );
  }
}

void postLoginCredentialsToBackend(LoginCredentials loginCredentials) {
  if (!testMode) {
    http.post(
      Uri.parse(apiGateway + postLogin),
      body: loginCredentials.toJson(),
    );
  }
}

void postReviewOnBackend(Response response) {
  if (!testMode) {
    final json = response.toJson();
    json[Fields.painPoints] =
        (json[Fields.painPoints] as Map<String, String>).keys.toList();
    http.post(
      Uri.parse(apiGateway + postReview),
      body: json,
    );
  }
}
