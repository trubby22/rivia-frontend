class JH {
  static T toss<T>(String errMsg) {
    throw Exception(errMsg);
  }

  static List<T> asList<T>(
    dynamic jason, {
    String? Function(Type)? listErrMsg,
    String? castErrMsg,
  }) {
    try {
      final List<dynamic> _ = jason;
    } catch (_) {
      Exception(
        listErrMsg?.call(jason.runtimeType) ??
            "The type of the JSON object should be a list, but is a ${jason.runtimeType}",
      );
    }

    try {
      final List<T> list = (jason as List<dynamic>).cast();
      return list;
    } catch (e) {
      throw Exception(castErrMsg ?? e.toString());
    }
  }
}
