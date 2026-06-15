import 'package:flutter/material.dart';

/// Logical max width for centered phone-style app content on wide screens.
const double kPhoneMaxContentWidth = 430.0;

/// Centers content in a phone-width column with standard screen padding.
class PhoneWidthLayout extends StatelessWidget {
  const PhoneWidthLayout({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
  });

  final Widget child;
  final bool useSafeArea;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kPhoneMaxContentWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (!useSafeArea) return content;
    return SafeArea(child: content);
  }
}

/// Compact AppBar action: icon button with tooltip for secondary navigation.
class CompactAppBarIconAction extends StatelessWidget {
  const CompactAppBarIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon),
    );
  }
}
