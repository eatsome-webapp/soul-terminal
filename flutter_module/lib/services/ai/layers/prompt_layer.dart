import '../../../models/prompt_context.dart';

/// Base interface for composable system prompt layers.
///
/// Each layer produces a section of the final system prompt.
/// Layers are composed in priority order by [PromptComposer].
abstract class PromptLayer {
  /// Human-readable name for this layer (used as section header).
  String get layerName;

  /// Sort priority — lower numbers appear first in the prompt.
  int get priority;

  /// Composes this layer's content given the current context.
  Future<String> compose(PromptContext context);

  /// Placeholder text when this layer has no content.
  /// Return empty string to omit the section entirely.
  String get emptyPlaceholder;
}
