extension DateTimeJson on DateTime {
  static DateTime? fromJSON(dynamic json) {
    if (json.runtimeType == double) {
      return DateTime.fromMillisecondsSinceEpoch((json * 1000).toInt());
    }

    if (json.runtimeType == int) {
      return DateTime.fromMillisecondsSinceEpoch((json * 1000));
    }

    return null;
  }

  double toJSON() => millisecondsSinceEpoch / 1000;
}
