import '../../core/constants.dart';

/// Selects the appropriate Claude model based on query complexity.
///
/// Uses keyword heuristics and message length to determine whether
/// a query needs deep reasoning (Opus) or fast response (Sonnet).
/// Defaults to Sonnet for cost efficiency.
class ModelRouter {
  /// Keywords that indicate complex, strategic reasoning requiring Opus.
  static const List<String> _opusKeywords = [
    'pivot',
    'strategy',
    'should i',
    'business model',
    'architecture',
    'tradeoff',
    'trade-off',
    'compare',
    'evaluate',
    'decision',
    'pros and cons',
    'long-term',
    'long term',
    'fundraising',
    'pricing',
    'go-to-market',
    'competitive',
    'moat',
    'runway',
    'burn rate',
  ];

  /// Minimum message length (chars) that triggers Opus selection.
  static const int _longMessageThreshold = 500;

  /// Selects Claude model based on query complexity.
  /// Returns Opus for strategic/complex queries, Sonnet for everything else.
  String select(String userText) {
    final lowerText = userText.toLowerCase();

    final isComplex = _opusKeywords.any((kw) => lowerText.contains(kw));
    final isLong = userText.length > _longMessageThreshold;

    return (isComplex || isLong)
        ? SoulConstants.complexModel
        : SoulConstants.defaultModel;
  }
}
