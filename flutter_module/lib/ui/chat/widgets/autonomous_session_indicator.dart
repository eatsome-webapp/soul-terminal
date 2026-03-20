import 'dart:async';

import 'package:flutter/material.dart';

/// AppBar indicator showing autonomous session status.
///
/// Displays a pulsing dot (opacity 0.3-1.0, 1500ms cycle),
/// "Autonoom" label (hidden on screens <360dp), and elapsed time (M:SS).
class AutonomousSessionIndicator extends StatefulWidget {
  final DateTime startedAt;

  const AutonomousSessionIndicator({
    super.key,
    required this.startedAt,
  });

  @override
  State<AutonomousSessionIndicator> createState() =>
      _AutonomousSessionIndicatorState();
}

class _AutonomousSessionIndicatorState
    extends State<AutonomousSessionIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late Timer _elapsedTimer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _elapsed = DateTime.now().difference(widget.startedAt);
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(widget.startedAt);
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _elapsedTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Opacity(
              opacity: 0.3 + (_pulseController.value * 0.7),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          if (MediaQuery.of(context).size.width > 360) ...[
            Text(
              'Autonoom',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            '${_elapsed.inMinutes}:${(_elapsed.inSeconds % 60).toString().padLeft(2, '0')}',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
