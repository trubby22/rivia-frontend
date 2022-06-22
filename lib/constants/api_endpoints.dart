import 'package:rivia/utilities/change_notifiers.dart';

class API {
  static String apiGateway = 'https://api.rivia.me';

  static String summary() => '$apiGateway/summary';

  /// Get Preset Questions.
  static String getPresets() =>
      '$apiGateway/?tenant=${authToken.tenantId}&user=${authToken.userId}';

  /// Get the content of the [Meeting] corresponding to [meetingId].
  static String meeting(String meetingId) =>
      '$apiGateway/meeting/$meetingId/review';

  /// Post review to the [Meeting] corresponding to [meetingId].
  static String getReview(String meetingId) =>
      '$apiGateway/meetings/$meetingId/reviews?tenant=${authToken.tenantId}&user=${authToken.userId}';

  /// TODO: DEPRICATED
  static String meetingReviews() => '$apiGateway/reviews';

  /// Get all [Meeting]s.
  static String getMeetings() =>
      '$apiGateway/meetings?tenant=${authToken.tenantId}&user=${authToken.userId}';

  /// Get isReviewed.
  static String getIsReviewed(String meetingId) =>
      '$apiGateway/meetings/$meetingId/reviews?tenant=${authToken.tenantId}&user=${authToken.userId}';

  /// Get the [Meeting] corresponding to the meetingId.
  static String getMeeting(String meetingId) =>
      '$apiGateway/meetings/$meetingId?tenant=${authToken.tenantId}&user=${authToken.userId}';

  /// Get all [Participant]s.
  static String getParticipants() => '$apiGateway/meeting/create';

  /// Create a new [Meeting].
  static String postMeeting() =>
      '$apiGateway/meetings?tenant=${authToken.tenantId}&user=${authToken.userId}';

  /// Get Preset Questions.
  static String postPresets() => '$apiGateway/?tenant=${authToken.tenantId}';

  /// Login.
  static String postLogin() => '$apiGateway/login';

  /// Sign Up.
  static String postSignUp() => '$apiGateway/create-account';

  static String timing() =>
      '$apiGateway/timing?tenant=${authToken.tenantId}&user=${authToken.userId}';

  static String rating() =>
      '$apiGateway/rating?tenant=${authToken.tenantId}&user=${authToken.userId}';
}
