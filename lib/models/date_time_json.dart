extension DateTimeJson on DateTime {
  static DateTime fromJSON(double json) =>
      DateTime.fromMillisecondsSinceEpoch((json * 1000).toInt());

  double toJSON() => millisecondsSinceEpoch / 1000;
}
