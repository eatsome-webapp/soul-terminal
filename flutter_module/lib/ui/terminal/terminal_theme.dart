import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart';

/// Dark terminal theme — always dark regardless of app theme.
/// Terminal convention: dark background, light text.
class SoulTerminalTheme {
  static const terminalTheme = TerminalTheme(
    cursor: Color(0xFFE0E0E0),
    selection: Color(0x40FFFFFF),
    foreground: Color(0xFFE0E0E0),
    background: Color(0xFF1A1A2E),
    black: Color(0xFF000000),
    white: Color(0xFFE0E0E0),
    red: Color(0xFFFF6B6B),
    green: Color(0xFF69FF94),
    yellow: Color(0xFFFFF56D),
    blue: Color(0xFF6CB6FF),
    magenta: Color(0xFFD78BFF),
    cyan: Color(0xFF70D7FF),
    brightBlack: Color(0xFF666666),
    brightRed: Color(0xFFFF8A8A),
    brightGreen: Color(0xFF8BFFAD),
    brightYellow: Color(0xFFFFF98A),
    brightBlue: Color(0xFF8ECAFF),
    brightMagenta: Color(0xFFE8ABFF),
    brightCyan: Color(0xFF8FE4FF),
    brightWhite: Color(0xFFFFFFFF),
    searchHitBackground: Color(0xFF665C00),
    searchHitBackgroundCurrent: Color(0xFFFFE81A),
    searchHitForeground: Color(0xFF000000),
  );

  static const textStyle = TerminalStyle(fontSize: 14);
}
