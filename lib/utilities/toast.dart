import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

final fToast = FToast();

void showToast({
  required BuildContext context,
  required String text,
  bool success = true,
}) {
  fToast.init(context);
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.grey.shade100,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        success
            ? const Icon(Icons.check_outlined)
            : const Icon(Icons.error_outline),
        const SizedBox(width: 12.0),
        Text(text),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 2),
  );
}
