import 'package:flutter/material.dart';

/// Animated 3-dot pulsing indicator shown while waiting for first token.
class StreamingIndicator extends StatefulWidget {
  const StreamingIndicator({super.key});

  @override
  State<StreamingIndicator> createState() => _StreamingIndicatorState();
}

class _StreamingIndicatorState extends State<StreamingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Semantics(
      label: 'SOUL is thinking...',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Stagger each dot by 200ms (0.33 of the 600ms cycle)
              final delay = index * 0.33;
              final value = (_controller.value + delay) % 1.0;
              // Sine wave for smooth pulse, mapping to 0.3-1.0 opacity
              final opacity = 0.3 + 0.7 * _pulse(value);

              return Padding(
                padding: EdgeInsets.only(left: index > 0 ? 4 : 0),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  /// Produces a smooth pulse from 0.0 to 1.0 and back using sine.
  double _pulse(double t) {
    // Map 0..1 to 0..pi for a single bump
    return (t < 0.5)
        ? (t * 2) // rising 0..1
        : (1 - (t - 0.5) * 2); // falling 1..0
  }
}
