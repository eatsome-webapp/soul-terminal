import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants.dart';
import '../../../models/conversation.dart';
import 'message_action_row.dart';

/// Renders a single chat message bubble.
///
/// User messages are right-aligned with primaryContainer background.
/// Assistant messages are full-width with surfaceContainerHigh background
/// and markdown rendering via [MarkdownBody].
class MessageBubble extends StatefulWidget {
  final Message message;
  final bool isStreaming;
  final bool showSoulLabel;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
    this.showSoulLabel = false,
    this.onCopy,
    this.onShare,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  String _displayContent = '';
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _displayContent = widget.message.content;
  }

  @override
  void didUpdateWidget(MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isStreaming && widget.message.content != _displayContent) {
      // Debounce markdown re-renders during streaming at 100ms
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        const Duration(
          milliseconds: SoulConstants.markdownDebounceDuration,
        ),
        () {
          if (mounted) {
            setState(() {
              _displayContent = widget.message.content;
            });
          }
        },
      );
    } else if (!widget.isStreaming) {
      _debounceTimer?.cancel();
      if (_displayContent != widget.message.content) {
        _displayContent = widget.message.content;
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.role == MessageRole.user;

    return RepaintBoundary(
      child: GestureDetector(
        onLongPress: widget.onCopy,
        child: Semantics(
          label: isUser
              ? 'Your message: ${widget.message.content}'
              : 'Message from SOUL: ${widget.message.content}',
          child: isUser ? _buildUserBubble(context) : _buildAssistantBubble(context),
        ),
      ),
    );
  }

  Widget _buildUserBubble(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _displayContent,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 4),
            _buildTimestamp(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistantBubble(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showSoulLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4),
            child: Text(
              'SOUL',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _displayContent.isEmpty
              ? const SizedBox.shrink()
              : MarkdownBody(
                  data: _displayContent,
                  selectable: true,
                  styleSheet: _buildMarkdownStyleSheet(context),
                  builders: {
                    'code': _CodeBlockBuilder(colorScheme: colorScheme),
                  },
                ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildTimestamp(context),
            if (!widget.isStreaming && widget.onCopy != null && widget.onShare != null) ...[
              const Spacer(),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isStreaming ? 0.0 : 1.0,
                child: MessageActionRow(
                  onCopy: widget.onCopy!,
                  onShare: widget.onShare!,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTimestamp(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        _formatRelativeTime(widget.message.createdAt),
        style: textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MarkdownStyleSheet(
      p: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      strong: textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      code: GoogleFonts.jetBrainsMono(
        fontSize: 14,
        height: 1.57,
        color: colorScheme.onSurface.withValues(alpha: 0.87),
        backgroundColor: colorScheme.surfaceContainerHighest,
      ),
      codeblockDecoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      listBullet: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      a: textTheme.bodyLarge?.copyWith(color: colorScheme.primary),
    );
  }

  String _formatRelativeTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${time.month}/${time.day}';
  }
}

/// Custom code block builder for syntax highlighting.
class _CodeBlockBuilder extends MarkdownElementBuilder {
  final ColorScheme colorScheme;

  _CodeBlockBuilder({required this.colorScheme});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final code = element.textContent;
    // Try to extract language from info string
    String? language;
    if (element.attributes.containsKey('class')) {
      final classAttr = element.attributes['class'] ?? '';
      if (classAttr.startsWith('language-')) {
        language = classAttr.substring(9);
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: HighlightView(
        code,
        language: language ?? 'plaintext',
        theme: monokaiSublimeTheme,
        textStyle: GoogleFonts.jetBrainsMono(
          fontSize: 14,
          height: 1.57,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
