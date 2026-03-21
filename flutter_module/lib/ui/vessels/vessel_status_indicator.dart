import 'package:flutter/material.dart';

import '../../services/vessels/models/vessel_connection.dart';

/// Small badge showing vessel connection status with a colored dot.
///
/// - Connected: `primary` dot
/// - Disconnected: `error` dot
/// - Connecting: pulsing `onSurfaceVariant` dot (1000ms easeInOut)
/// - Error: `error` dot
class VesselStatusIndicator extends StatefulWidget {
  final String vesselName;
  final ConnectionStatus status;

  const VesselStatusIndicator({
    super.key,
    required this.vesselName,
    required this.status,
  });

  @override
  State<VesselStatusIndicator> createState() => _VesselStatusIndicatorState();
}

class _VesselStatusIndicatorState extends State<VesselStatusIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupPulse();
  }

  @override
  void didUpdateWidget(VesselStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status) {
      _setupPulse();
    }
  }

  void _setupPulse() {
    if (widget.status == ConnectionStatus.connecting) {
      _pulseController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1000),
      );
      _pulseAnimation = CurvedAnimation(
        parent: _pulseController!,
        curve: Curves.easeInOut,
      );
      _pulseController!.repeat(reverse: true);
    } else {
      _pulseController?.stop();
    }
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  Color _dotColor(ColorScheme colorScheme) {
    return switch (widget.status) {
      ConnectionStatus.connected => colorScheme.primary,
      ConnectionStatus.disconnected => colorScheme.error,
      ConnectionStatus.connecting => colorScheme.onSurfaceVariant,
      ConnectionStatus.error => colorScheme.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final dotColor = _dotColor(colorScheme);

    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: dotColor,
        shape: BoxShape.circle,
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.status == ConnectionStatus.connecting &&
            _pulseAnimation != null)
          FadeTransition(opacity: _pulseAnimation!, child: dot)
        else
          dot,
        const SizedBox(width: 4),
        Text(
          widget.vesselName,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
