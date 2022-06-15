import 'package:rivia/utilities/change_notifiers.dart';

class API {
  static String apiGateway = 'https://api.rivia.me';

  static String summary() => '$apiGateway/summary';

  /// Get the content of the [Meeting] corresponding to [meetingId].
  static String meeting(String meetingId) =>
      '$apiGateway/meeting/$meetingId/review';

  /// Post review to the [Meeting] corresponding to [meetingId].
  static String getReview(String meetingId) =>
      '$apiGateway/tenants/${authToken.tenantDomain}/meetings/$meetingId/review?user=${authToken.userId}';

  /// TODO: get all responses to the review survey. Prolly will need meetingId.
  static String meetingReviews() => '$apiGateway/reviews';

  /// Get all [Meeting]s.
  static String getMeetings() =>
      '$apiGateway/tenants/${authToken.tenantDomain}/meetings?user=${authToken.userId}';

  /// Get the [Meeting] corresponding to the meetingId.
  static String getMeeting(String meetingId) =>
      '$apiGateway/tenants/${authToken.tenantDomain}/meetings/$meetingId?user=${authToken.userId}';

  /// Get all [Participant]s.
  static String getParticipants() => '$apiGateway/meeting/create';

  /// Create a new [Meeting].
  static String postMeeting() =>
      '$apiGateway/tenants/${authToken.tenantDomain}/meetings?user=${authToken.userId}';

  /// Login.
  static String postLogin() => '$apiGateway/login';

  /// Sign Up.
  static String postSignUp() => '$apiGateway/create-account';
}
