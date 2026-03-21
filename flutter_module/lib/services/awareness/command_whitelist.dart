/// Security whitelist for destructive terminal commands.
///
/// Detects destructive patterns before SOUL executes commands in the terminal.
/// All matching is case-insensitive on executable, exact on flags.
class CommandWhitelist {
  /// Check structured command against destructive patterns.
  /// Returns true if command is destructive and needs confirmation.
  static bool isDestructive(String executable, List<String> args) {
    return getDestructiveReason(executable, args) != null;
  }

  /// Check combined string for destructive patterns.
  /// Returns Dutch description of why it's destructive, or null if safe.
  static String? getDestructiveReason(String executable, List<String> args) {
    final exec = executable.toLowerCase();

    // Pattern 1: rm with recursive + force flags
    if (exec == 'rm') {
      return _checkRmFlags(args);
    }

    // Pattern 2: dd with input file (data destroyer)
    if (exec == 'dd') {
      final hasInputFile = args.any((arg) => arg.startsWith('if='));
      if (hasInputFile) {
        return 'dd met if= overschrijft of vernietigt een apparaat of bestand';
      }
    }

    // Pattern 3: mkfs (any variant, any args)
    if (exec == 'mkfs' || exec.startsWith('mkfs.')) {
      return 'mkfs formatteert een bestandssysteem en verwijdert alle data';
    }

    // Pattern 4: git reset --hard
    if (exec == 'git') {
      final hasReset = args.contains('reset');
      final hasHard = args.contains('--hard');
      if (hasReset && hasHard) {
        return 'git reset --hard verwijdert niet-gecommitte wijzigingen permanent';
      }
    }

    // Pattern 5: chmod -R 777
    if (exec == 'chmod') {
      final hasRecursive = args.contains('-R') || args.contains('--recursive');
      final has777 = args.contains('777');
      if (hasRecursive && has777) {
        return 'chmod -R 777 maakt alle bestanden wereldwijd schrijfbaar — beveiligingsrisico';
      }
    }

    // Pattern 6: shell with -c flag — scan inner command
    if (exec == 'bash' || exec == 'sh' || exec == 'zsh') {
      final cFlagIndex = args.indexOf('-c');
      if (cFlagIndex != -1 && cFlagIndex + 1 < args.length) {
        final innerCommand = args[cFlagIndex + 1];
        return _checkInnerCommand(innerCommand);
      }
    }

    // Pattern 7: fork bomb detection in any arg
    final allArgs = args.join(' ');
    if (_isForkBomb(allArgs)) {
      return 'fork bomb patroon gedetecteerd — kan systeem onbruikbaar maken';
    }

    return null;
  }

  /// Check rm flags for recursive + force combination.
  static String? _checkRmFlags(List<String> args) {
    bool hasRecursive = false;
    bool hasForce = false;

    for (final arg in args) {
      // Long flags
      if (arg == '--recursive') hasRecursive = true;
      if (arg == '--force') hasForce = true;

      // Short flags — can be combined like -rf, -Rf, -fr, -r, -f etc.
      if (arg.startsWith('-') && !arg.startsWith('--')) {
        final flags = arg.substring(1);
        if (flags.contains('r') || flags.contains('R')) hasRecursive = true;
        if (flags.contains('f')) hasForce = true;
      }
    }

    if (hasRecursive && hasForce) {
      return 'rm -rf verwijdert bestanden recursief en geforceerd';
    }
    return null;
  }

  /// Scan inner command string (from bash -c "...") for destructive patterns.
  static String? _checkInnerCommand(String command) {
    // Fork bomb
    if (_isForkBomb(command)) {
      return 'fork bomb patroon gedetecteerd in shell -c commando';
    }

    // > /dev/sda (direct device write)
    if (command.contains('> /dev/sda') || command.contains('>/dev/sda')) {
      return 'directe schrijfoperatie naar apparaat gedetecteerd';
    }

    // rm -rf patterns
    final rmRfPattern = RegExp(r'\brm\s+.*-[a-zA-Z]*r[a-zA-Z]*f|rm\s+.*-[a-zA-Z]*f[a-zA-Z]*r\b', caseSensitive: false);
    if (rmRfPattern.hasMatch(command)) {
      return 'rm -rf gedetecteerd in shell -c commando';
    }

    // dd if= pattern
    if (RegExp(r'\bdd\b.*\bif=').hasMatch(command)) {
      return 'dd met if= gedetecteerd in shell -c commando';
    }

    // mkfs pattern
    if (RegExp(r'\bmkfs\b').hasMatch(command)) {
      return 'mkfs gedetecteerd in shell -c commando';
    }

    // git reset --hard
    if (RegExp(r'\bgit\s+reset\s+--hard\b').hasMatch(command)) {
      return 'git reset --hard gedetecteerd in shell -c commando';
    }

    // chmod -R 777
    if (RegExp(r'\bchmod\s+.*-R.*777\b').hasMatch(command)) {
      return 'chmod -R 777 gedetecteerd in shell -c commando';
    }

    return null;
  }

  /// Detect fork bomb patterns like :(){:|:&};: or f(){ f|f&};f
  static bool _isForkBomb(String input) {
    // Classic fork bomb signature: function definition with pipe and background
    return input.contains('(){') && input.contains('|') && input.contains('&}');
  }
}
