import 'package:flutter/material.dart';

class SizedButton extends StatefulWidget {
  const SizedButton({
    Key? key,
    this.width = 48.0,
    this.height = 48.0,
    this.primaryColour = Colors.lightBlue,
    this.backgroundColour = Colors.white,
    this.onPressedColour = Colors.blue,
    required this.child,
    this.onPressed,
  }) : super(key: key);

  final double width;
  final double height;
  final Color? primaryColour;
  final Color? backgroundColour;
  final Color? onPressedColour;
  final Widget child;
  final Function(bool)? onPressed;

  @override
  State<SizedButton> createState() => _SizedButtonState();
}

class _SizedButtonState extends State<SizedButton> {
  bool _value = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: widget.height,
      width: widget.width,
      child: TextButton(
        child: widget.child,
        onPressed: () => setState(
          () {
            widget.onPressed?.call(_value);
            _value = !_value;
          },
        ),
        style: TextButton.styleFrom(
          primary: _value ? widget.backgroundColour : widget.primaryColour,
          padding: EdgeInsets.zero,
          splashFactory: NoSplash.splashFactory,
          side: BorderSide(color: _value ? Colors.white : Colors.lightBlue),
        ).merge(
          ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
              (Set<MaterialState> states) =>
                  states.contains(MaterialState.pressed)
                      ? widget.onPressedColour
                      : _value
                          ? widget.onPressedColour
                          : widget.backgroundColour,
            ),
          ),
        ),
      ),
    );
  }
}
