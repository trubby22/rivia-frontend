import 'package:flutter/material.dart';

class SizedButton extends StatelessWidget {
  const SizedButton({
    Key? key,
    this.isSelected = false,
    this.width = 52.0,
    this.borderWidth = 0,
    this.borderColour = Colors.transparent,
    this.height = 52.0,
    this.primaryColour = Colors.blue,
    this.backgroundColour = Colors.white,
    this.onPressedColour = Colors.lightBlue,
    this.padding = const EdgeInsets.all(8.0),
    this.radius = const BorderRadius.all(Radius.circular(8.0)),
    required this.child,
    this.useShadow = true,
    this.onPressed,
  }) : super(key: key);

  final bool isSelected;
  final double? width;
  final double? height;
  final double borderWidth;
  final Color borderColour;
  final Color primaryColour;
  final Color backgroundColour;
  final Color onPressedColour;
  final Widget child;
  final BorderRadius radius;
  final EdgeInsets? padding;
  final bool useShadow;
  final Function(bool)? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: useShadow
            ? const [BoxShadow(offset: Offset(0, 1), blurRadius: 2.0)]
            : const [],
      ),
      child: TextButton(
        child: Container(child: child),
        onPressed: () => onPressed?.call(isSelected),
        style: TextButton.styleFrom(
          primary: isSelected ? backgroundColour : primaryColour,
          padding: padding,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: borderColour, width: borderWidth),
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
