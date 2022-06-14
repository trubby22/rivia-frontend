import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A combination of [GestureDetector] and [MouseRegion].
class MouseClicker extends StatelessWidget {
  const MouseClicker({
    Key? key,
    required this.child,
    this.onEnter,
    this.onExit,
    this.onHover,
    this.onTap,
  }) : super(key: key);

  final Widget child;
  final void Function(PointerEnterEvent)? onEnter;
  final void Function(PointerHoverEvent)? onHover;
  final void Function(PointerExitEvent)? onExit;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: onEnter,
      onHover: onHover,
      onExit: onExit,
      child: GestureDetector(onTap: onTap, child: child),
    );
  }
}
