class SoulConstants {
  static const String appName = 'SOUL';
  static const int maxTokens = 4096;
  static const String defaultModel = 'claude-sonnet-4-20250514';
  static const String complexModel = 'claude-opus-4-20250514';
  static const int systemPromptCacheMinTokens = 1024;
  static const int markdownDebounceDuration = 100; // ms
  static const int scrollAnimationDuration = 300; // ms
  static const int maxConversationTitleLength = 40;

  // Agentic Engine defaults
  static const int defaultMaxIterations = 25;
  static const double defaultCostLimitUsd = 1.0;
  static const double sonnetInputCostPerMTok = 3.0;
  static const double sonnetOutputCostPerMTok = 15.0;
  static const double opusInputCostPerMTok = 15.0;
  static const double opusOutputCostPerMTok = 75.0;

  static const double haikuInputCostPerMTok = 0.25;
  static const double haikuOutputCostPerMTok = 1.25;
  static const String haikuModel = 'claude-3-5-haiku-20241022';

  // Cache pricing multipliers (relative to input cost)
  static const double cacheCreationMultiplier = 1.25; // 25% more than input
  static const double cacheReadMultiplier = 0.1; // 90% less than input
}
