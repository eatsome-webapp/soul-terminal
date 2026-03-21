import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Text input field with send/stop button for the chat screen.
///
/// Shows a send button (arrow up) when idle and a stop button when streaming.
/// Shift+Enter inserts newline, Enter alone sends.
class MessageInput extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onStop;
  final bool isStreaming;
  final bool enabled;

  const MessageInput({
    super.key,
    required this.onSend,
    this.onStop,
    this.isStreaming = false,
    this.enabled = true,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    _scaleController.forward().then((_) => _scaleController.reverse());

    widget.onSend(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (event is KeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.enter &&
                    !HardwareKeyboard.instance.isShiftPressed) {
                  _handleSend();
                }
              },
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Message SOUL...',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildActionButton(context),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isStreaming) {
      return Semantics(
        label: 'Stop generating',
        child: SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: widget.onStop,
            icon: Icon(
              Icons.stop_circle_outlined,
              color: colorScheme.error,
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: 'Send message',
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            onPressed: _hasText && widget.enabled ? _handleSend : null,
            style: IconButton.styleFrom(
              backgroundColor:
                  _hasText && widget.enabled ? colorScheme.primary : colorScheme.primary.withValues(alpha: 0.38),
            ),
            icon: Icon(
              Icons.arrow_upward,
              color: _hasText && widget.enabled
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimary.withValues(alpha: 0.38),
            ),
          ),
        ),
      ),
    );
  }
}
