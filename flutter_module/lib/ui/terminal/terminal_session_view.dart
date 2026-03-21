import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

import 'terminal_session.dart';
import 'terminal_theme.dart';

/// Renders a single terminal session with xterm emulation.
/// Shows a placeholder when no vessel is connected.
class TerminalSessionView extends StatelessWidget {
  final TerminalSession session;
  final VoidCallback? onInput;

  const TerminalSessionView({
    super.key,
    required this.session,
    this.onInput,
  });

  @override
  Widget build(BuildContext context) {
    if (!session.isConnected) {
      return _buildDisconnectedPlaceholder(context);
    }

    return Container(
      color: const Color(0xFF1A1A2E),
      child: TerminalView(
        session.terminal,
        textStyle: SoulTerminalTheme.textStyle,
        theme: SoulTerminalTheme.terminalTheme,
      ),
    );
  }

  Widget _buildDisconnectedPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: const Color(0xFF1A1A2E),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.terminal,
              size: 48,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Verbind een vessel in Settings',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
            ),
            if (session.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                session.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
