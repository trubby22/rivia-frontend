import 'package:rivia/utilities/change_notifiers.dart';

class API {
  static String apiGateway = 'https://api.rivia.me';

  static String summary() => '$apiGateway/summary';

  /// Get the content of the [Meeting] corresponding to [meetingId].
  static String meeting(String meetingId) =>
      '$apiGateway/meeting/$meetingId/review';

  /// Post review to the [Meeting] corresponding to [meetingId].
  static String getReview(String meetingId) =>
      '$apiGateway/meetings/$meetingId/reviews?tenant=${authToken.tenantDomain}&user=${authToken.userId}';

  /// TODO: DEPRICATED
  static String meetingReviews() => '$apiGateway/reviews';

  /// Get all [Meeting]s.
  static String getMeetings() =>
      '$apiGateway/meetings?tenant=${authToken.tenantDomain}&user=${authToken.userId}';

  /// Get isReviewed.
  static String getIsReviewed(String meetingId) =>
      '$apiGateway/meetings/$meetingId/reviews?tenant=${authToken.tenantDomain}&user=${authToken.userId}';

  /// Get the [Meeting] corresponding to the meetingId.
  static String getMeeting(String meetingId) =>
      '$apiGateway/meetings/$meetingId?tenant=${authToken.tenantDomain}&user=${authToken.userId}';

  /// Get all [Participant]s.
  static String getParticipants() => '$apiGateway/meeting/create';

  /// Create a new [Meeting].
  static String postMeeting() =>
      '$apiGateway/meetings?tenant=${authToken.tenantDomain}&user=${authToken.userId}';

  /// Login.
  static String postLogin() => '$apiGateway/login';

  /// Sign Up.
  static String postSignUp() => '$apiGateway/create-account';
}
