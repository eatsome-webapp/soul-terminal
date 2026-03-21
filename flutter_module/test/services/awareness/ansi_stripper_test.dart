import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_module/services/awareness/ansi_stripper.dart';

void main() {
  group('AnsiStripper.strip', () {
    group('CSI color sequences', () {
      test('CSI red color is stripped', () {
        expect(AnsiStripper.strip('\x1B[31mred text\x1B[0m'), equals('red text'));
      });

      test('CSI bold+green color is stripped', () {
        expect(
          AnsiStripper.strip('\x1B[1;32mbold green\x1B[0m'),
          equals('bold green'),
        );
      });

      test('CSI clear screen is stripped', () {
        expect(AnsiStripper.strip('\x1B[2J\x1B[Hcontent'), equals('content'));
      });

      test('CSI cursor show/hide is stripped', () {
        expect(AnsiStripper.strip('\x1B[?25h\x1B[?25l'), equals(''));
      });
    });

    group('OSC sequences', () {
      test('OSC title with BEL terminator is stripped', () {
        expect(
          AnsiStripper.strip('\x1B]0;My Title\x07output'),
          equals('output'),
        );
      });

      test('OSC title with ST terminator is stripped', () {
        expect(
          AnsiStripper.strip('\x1B]0;title\x1B\\output'),
          equals('output'),
        );
      });
    });

    group('Bracketed paste', () {
      test('bracketed paste markers are stripped, content preserved', () {
        expect(
          AnsiStripper.strip('\x1B[200~pasted\x1B[201~'),
          equals('pasted'),
        );
      });
    });

    group('Single-char escapes', () {
      test('single-char escape \\x1BM is stripped', () {
        expect(AnsiStripper.strip('\x1BMtext'), equals('text'));
      });
    });

    group('Control characters', () {
      test('control characters 0x01 and 0x02 are stripped', () {
        expect(AnsiStripper.strip('hello\x01\x02world'), equals('helloworld'));
      });

      test('0x08 (backspace) is stripped', () {
        expect(AnsiStripper.strip('ab\x08c'), equals('abc'));
      });
    });

    group('Whitespace preservation', () {
      test('plain text with newline is unchanged', () {
        expect(AnsiStripper.strip('Hello world\n'), equals('Hello world\n'));
      });

      test('tab is preserved', () {
        expect(AnsiStripper.strip('col1\tcol2'), equals('col1\tcol2'));
      });

      test('carriage return is preserved', () {
        expect(AnsiStripper.strip('line\r\n'), equals('line\r\n'));
      });
    });

    group('Mixed content', () {
      test('colored prompt with file listing output', () {
        expect(
          AnsiStripper.strip('\x1B[32m\$ ls\x1B[0m\nfile1\nfile2'),
          equals('\$ ls\nfile1\nfile2'),
        );
      });

      test('output without any escapes is returned as-is', () {
        const plain = 'Build succeeded in 10 steps';
        expect(AnsiStripper.strip(plain), equals(plain));
      });
    });
  });
}
