class API {
  static String apiGateway = 'https://api.rivia.me';

  static String summary() => '$apiGateway/summary';

  /// Get the content of the [Meeting] corresponding to [meetingId].
  static String meeting(String meetingId) =>
      '$apiGateway/meeting/$meetingId/review';

  /// TODO: get all responses to the review survey. Prolly will need meetingId.
  static String meetingReviews() => '$apiGateway/reviews';

  /// Get all [Meeting]s.
  static String getMeetings(String tenantDomain, String userId) =>
      '$apiGateway/tenants/$tenantDomain/meetings?user=$userId';

  /// Get all [Participant]s.
  static String getParticipants() => '$apiGateway/meeting/create';

  /// Create a new [Meeting].
  static String postMeeting() => '$apiGateway/meeting/create';

  /// Login.
  static String postLogin() => '$apiGateway/login';

  /// Sign Up.
  static String postSignUp() => '$apiGateway/create-account';
}
