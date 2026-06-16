import 'dart:async';

import 'package:flutter/material.dart';

/// Animated "Battling." / "Battling.." / "Battling..." overlay text.
class BattlingDotsText extends StatefulWidget {
  const BattlingDotsText({
    super.key,
    this.style,
    this.interval = const Duration(milliseconds: 500),
  });

  final TextStyle? style;
  final Duration interval;

  @override
  State<BattlingDotsText> createState() => _BattlingDotsTextState();
}

class _BattlingDotsTextState extends State<BattlingDotsText> {
  var _dotCount = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      setState(() => _dotCount = _dotCount >= 3 ? 1 : _dotCount + 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;
    return Text(
      'Battling$dots',
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}
