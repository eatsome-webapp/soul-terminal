import 'package:flutter/material.dart';

/// Placeholder screen shown behind the native terminal overlay.
/// The actual terminal is rendered natively by Android and overlays this view
/// when the Terminal tab is active (controlled via Pigeon setTerminalVisible).
class TerminalScreen extends StatelessWidget {
  const TerminalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF0D0D1A),
      child: Center(
        child: Text(
          'Terminal actief',
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ),
    );
  }
}
