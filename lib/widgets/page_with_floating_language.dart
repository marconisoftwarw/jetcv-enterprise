import 'package:flutter/material.dart';
import 'floating_language_button.dart';

class PageWithFloatingLanguage extends StatelessWidget {
  final Widget child;
  final bool showFloatingButton;

  const PageWithFloatingLanguage({
    super.key,
    required this.child,
    this.showFloatingButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [child, if (showFloatingButton) const FloatingLanguageButton()],
    );
  }
}
