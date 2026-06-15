import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Logical max width for centered phone-style app content on wide screens.
const double kPhoneMaxContentWidth = 430.0;

const double _kPhoneAppBarSideSlotWidth = 48.0;

/// AppBar whose toolbar content aligns with [PhoneWidthLayout] on wide screens.
class PhoneWidthAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PhoneWidthAppBar({
    super.key,
    required this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.toolbarHeight = kToolbarHeight,
    this.horizontalPadding = 16,
    this.title,
    this.titleStyle,
  }) : titleWidget = null;

  const PhoneWidthAppBar.widget({
    super.key,
    required this.backgroundColor,
    required this.titleWidget,
    this.foregroundColor,
    this.elevation = 0,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.toolbarHeight = kToolbarHeight,
    this.horizontalPadding = 16,
  })  : title = null,
        titleStyle = null;

  final String? title;
  final Widget? titleWidget;
  final TextStyle? titleStyle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final double toolbarHeight;
  final double horizontalPadding;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  TextStyle? _resolvedTitleStyle(BuildContext context) {
    final base = titleStyle ??
        Theme.of(context).appBarTheme.titleTextStyle ??
        Theme.of(context).textTheme.titleLarge;
    final color = foregroundColor ?? Theme.of(context).appBarTheme.foregroundColor;
    return base?.copyWith(color: color ?? base.color);
  }

  Widget _buildTitle(BuildContext context) {
    if (titleWidget != null) {
      return _ellipsisTitle(titleWidget!, context);
    }

    return Text(
      title!,
      style: _resolvedTitleStyle(context),
      textAlign: TextAlign.center,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }

  Widget _ellipsisTitle(Widget title, BuildContext context) {
    if (title is Text) {
      final color = foregroundColor ?? Theme.of(context).appBarTheme.foregroundColor;
      return Text(
        title.data ?? '',
        style: (title.style ?? const TextStyle()).copyWith(
          color: title.style?.color ?? color,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        semanticsLabel: title.semanticsLabel,
      );
    }
    return title;
  }

  @override
  Widget build(BuildContext context) {
    final canPop = automaticallyImplyLeading &&
        (ModalRoute.of(context)?.canPop ?? false);
    final actionWidgets = actions ?? const <Widget>[];
    final trailingWidth = math.max(
      _kPhoneAppBarSideSlotWidth,
      actionWidgets.length * _kPhoneAppBarSideSlotWidth,
    );

    final Widget leadingWidget;
    if (leading != null) {
      leadingWidget = SizedBox(width: _kPhoneAppBarSideSlotWidth, child: leading);
    } else if (canPop) {
      leadingWidget = SizedBox(
        width: _kPhoneAppBarSideSlotWidth,
        child: BackButton(color: foregroundColor),
      );
    } else {
      leadingWidget = const SizedBox(width: _kPhoneAppBarSideSlotWidth);
    }

    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      toolbarHeight: toolbarHeight,
      title: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kPhoneMaxContentWidth),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              children: [
                leadingWidget,
                Expanded(
                  child: Center(child: _buildTitle(context)),
                ),
                SizedBox(
                  width: trailingWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actionWidgets,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
