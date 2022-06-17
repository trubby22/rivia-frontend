import 'package:flutter/material.dart';
import 'package:rivia/constants/route_names.dart';
import 'package:rivia/constants/settings.dart';
import 'package:rivia/constants/ui_texts.dart';
import 'package:rivia/utilities/sized_button.dart';
import 'package:rivia/utilities/change_notifiers.dart';

class LogOutButton extends StatelessWidget {
  const LogOutButton({Key? key, this.callback}) : super(key: key);

  final Function()? callback;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 140.0,
      top: 24.0,
      child: SizedButton(
        backgroundColour: const Color.fromRGBO(239, 198, 135, 1),
        primaryColour: Colors.black,
        onPressedColour: const Color.fromRGBO(239, 198, 135, 1),
        height: 48.0,
        width: 64.0,
        onPressed: (_) async {
          if (!testMode) {
            await authToken.reset();
          }
          Navigator.of(context).pushNamed(RouteNames.login, arguments: true);
        },
        child: const Icon(
          Icons.logout,
          size: FontSizes.bigTextSize,
          color: Colors.black,
        ),
      ),
    );
  }
}
