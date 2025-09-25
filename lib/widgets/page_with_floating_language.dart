import 'package:flutter/material.dart';
import 'floating_language_button.dart';

class PageWithFloatingLanguage extends StatelessWidget {
  final Widget child;
  final bool showFloatingButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final double? topPosition;
  final double? rightPosition;

  const PageWithFloatingLanguage({
    super.key,
    required this.child,
    this.showFloatingButton = true,
    this.floatingActionButtonLocation,
    this.topPosition,
    this.rightPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (showFloatingButton)
          FloatingLanguageButton(
            topPosition: topPosition,
            rightPosition: rightPosition,
          ),
      ],
    );
  }
}
