import 'package:flutter/material.dart';

class SizedButton extends StatelessWidget {
  const SizedButton({
    Key? key,
    this.isSelected = false,
    this.width = 52.0,
    this.borderSide = BorderSide.none,
    this.height = 52.0,
    this.primaryColour = Colors.blue,
    this.selectedColour,
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
  final BorderSide borderSide;
  final Color primaryColour;
  final Color? selectedColour;
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
        onPressed: onPressed == null ? null : () => onPressed?.call(isSelected),
        style: TextButton.styleFrom(
          primary:
              isSelected ? selectedColour ?? backgroundColour : primaryColour,
          padding: padding,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(borderRadius: radius, side: borderSide),
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
