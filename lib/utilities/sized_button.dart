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
    this.padding = const EdgeInsets.all(8.0),
    this.radius = 8.0,
    required this.child,
    this.onPressed,
  }) : super(key: key);

  final bool isSelected;
  final double? width;
  final double? height;
  final Color primaryColour;
  final Color backgroundColour;
  final Color onPressedColour;
  final Widget child;
  final double radius;
  final EdgeInsets? padding;
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
          padding: padding,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(
              color: isSelected ? backgroundColour : onPressedColour,
            ),
          ),
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
