import 'package:flutter/material.dart';

class SizedButton extends StatelessWidget {
  const SizedButton({
    Key? key,
    this.isSelected = false,
    this.width = 64.0,
    this.height = 64.0,
    this.primaryColour = Colors.blue,
    this.backgroundColour = Colors.white,
    this.onPressedColour = Colors.lightBlue,
    required this.child,
    this.onPressed,
  }) : super(key: key);

  final bool isSelected;
  final double? width;
  final double? height;
  final Color? primaryColour;
  final Color? backgroundColour;
  final Color? onPressedColour;
  final Widget child;
  final Function(bool)? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: height,
      width: width,
      child: TextButton(
        child: child,
        onPressed: () => onPressed?.call(isSelected),
        style: TextButton.styleFrom(
          primary: isSelected ? backgroundColour : primaryColour,
          padding: const EdgeInsets.all(8.0),
          splashFactory: NoSplash.splashFactory,
          side: BorderSide(color: isSelected ? Colors.white : Colors.lightBlue),
        ).merge(
          ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
              (Set<MaterialState> states) =>
                  states.contains(MaterialState.pressed)
                      ? onPressedColour
                      : isSelected
                          ? onPressedColour
                          : backgroundColour,
            ),
          ),
        ),
      ),
    );
  }
}
