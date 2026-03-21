/// Strips ANSI escape codes from terminal output for AI context.
///
/// Removes control sequences that are meaningful to terminal emulators
/// but noise for AI processing. Preserves newlines, carriage returns, and tabs.
class AnsiStripper {
  /// Regex that matches ANSI escape sequences:
  /// - CSI sequences: \x1B[ followed by params and final byte
  /// - OSC sequences: \x1B] to BEL or ST
  /// - Single-char escapes: \x1B followed by @-Z or \-_
  static final _ansiPattern = RegExp(
    r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~]|\][^\x07]*(?:\x07|\x1B\\))',
  );

  /// Matches bare control characters except \n (0x0A), \r (0x0D), \t (0x09).
  static final _controlChars = RegExp(
    r'[\x00-\x08\x0B\x0C\x0E-\x1A\x1C-\x1F\x7F]',
  );

  /// Strip ANSI escape codes and control characters from terminal output.
  /// Preserves newlines (\n), carriage returns (\r), and tabs (\t).
  static String strip(String input) {
    return input
        .replaceAll(_ansiPattern, '')
        .replaceAll(_controlChars, '');
  }
}
