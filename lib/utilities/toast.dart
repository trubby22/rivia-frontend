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
      color: Colors.grey.shade700,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        success
            ? const Icon(Icons.check_outlined, color: Colors.white)
            : const Icon(Icons.error_outline, color: Colors.white),
        const SizedBox(width: 12.0),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text(text, style: const TextStyle(color: Colors.white))),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 2),
  );
}
