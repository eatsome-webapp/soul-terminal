import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Red floating action button to stop an autonomous vessel session.
///
/// Visible only during active autonomous sessions.
/// Enters with ScaleTransition (200ms easeOut), exits with 150ms easeIn.
/// Triggers haptic feedback on tap.
class KillSwitchFAB extends StatefulWidget {
  final bool visible;
  final VoidCallback onTap;

  const KillSwitchFAB({
    super.key,
    required this.visible,
    required this.onTap,
  });

  @override
  State<KillSwitchFAB> createState() => _KillSwitchFABState();
}

class _KillSwitchFABState extends State<KillSwitchFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
    if (widget.visible) _controller.forward();
  }

  @override
  void didUpdateWidget(KillSwitchFAB oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) _controller.forward();
    if (!widget.visible && oldWidget.visible) _controller.reverse();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          widget.onTap();
        },
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
        tooltip: 'Stop autonome sessie',
        child: const Icon(Icons.stop_rounded, size: 24),
      ),
    );
  }
}
