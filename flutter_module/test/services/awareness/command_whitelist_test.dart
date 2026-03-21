import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_module/services/awareness/command_whitelist.dart';

void main() {
  group('CommandWhitelist.isDestructive', () {
    group('rm patterns', () {
      test('rm -rf / is destructive', () {
        expect(CommandWhitelist.isDestructive('rm', ['-rf', '/']), isTrue);
      });

      test('rm -r -f ~/projects is destructive (separate flags)', () {
        expect(
          CommandWhitelist.isDestructive('rm', ['-r', '-f', '~/projects']),
          isTrue,
        );
      });

      test('rm -Rf / is destructive (capital R)', () {
        expect(CommandWhitelist.isDestructive('rm', ['-Rf', '/']), isTrue);
      });

      test('rm --recursive --force is destructive (long flags)', () {
        expect(
          CommandWhitelist.isDestructive('rm', ['--recursive', '--force', '/tmp']),
          isTrue,
        );
      });

      test('rm file.txt is NOT destructive (no -rf)', () {
        expect(CommandWhitelist.isDestructive('rm', ['file.txt']), isFalse);
      });

      test('rm -r dir/ is NOT destructive (no -f, just recursive)', () {
        expect(CommandWhitelist.isDestructive('rm', ['-r', 'dir/']), isFalse);
      });
    });

    group('ls patterns', () {
      test('ls -la is NOT destructive', () {
        expect(CommandWhitelist.isDestructive('ls', ['-la']), isFalse);
      });
    });

    group('git patterns', () {
      test('git reset --hard is destructive', () {
        expect(
          CommandWhitelist.isDestructive('git', ['reset', '--hard']),
          isTrue,
        );
      });

      test('git reset --soft HEAD~1 is NOT destructive', () {
        expect(
          CommandWhitelist.isDestructive('git', ['reset', '--soft', 'HEAD~1']),
          isFalse,
        );
      });

      test('git status is NOT destructive', () {
        expect(CommandWhitelist.isDestructive('git', ['status']), isFalse);
      });

      test('git reset --hard HEAD is destructive', () {
        expect(
          CommandWhitelist.isDestructive('git', ['reset', '--hard', 'HEAD']),
          isTrue,
        );
      });
    });

    group('dd patterns', () {
      test('dd if=/dev/zero of=/dev/sda is destructive', () {
        expect(
          CommandWhitelist.isDestructive('dd', ['if=/dev/zero', 'of=/dev/sda']),
          isTrue,
        );
      });

      test('dd of=backup.img is NOT destructive (no if=)', () {
        expect(
          CommandWhitelist.isDestructive('dd', ['of=backup.img']),
          isFalse,
        );
      });
    });

    group('mkfs patterns', () {
      test('mkfs ext4 /dev/sda1 is destructive', () {
        expect(
          CommandWhitelist.isDestructive('mkfs', ['ext4', '/dev/sda1']),
          isTrue,
        );
      });

      test('mkfs.ext4 /dev/sda1 is destructive (starts with mkfs)', () {
        expect(
          CommandWhitelist.isDestructive('mkfs.ext4', ['/dev/sda1']),
          isTrue,
        );
      });
    });

    group('chmod patterns', () {
      test('chmod -R 777 / is destructive', () {
        expect(
          CommandWhitelist.isDestructive('chmod', ['-R', '777', '/']),
          isTrue,
        );
      });

      test('chmod 755 file.sh is NOT destructive', () {
        expect(
          CommandWhitelist.isDestructive('chmod', ['755', 'file.sh']),
          isFalse,
        );
      });
    });

    group('bash -c nested detection', () {
      test('bash -c "rm -rf /" is destructive', () {
        expect(
          CommandWhitelist.isDestructive('bash', ['-c', 'rm -rf /']),
          isTrue,
        );
      });

      test('sh -c "dd if=/dev/zero of=/dev/sda" is destructive', () {
        expect(
          CommandWhitelist.isDestructive('sh', ['-c', 'dd if=/dev/zero of=/dev/sda']),
          isTrue,
        );
      });

      test('bash -c "echo hello" is NOT destructive', () {
        expect(
          CommandWhitelist.isDestructive('bash', ['-c', 'echo hello']),
          isFalse,
        );
      });

      test('zsh -c "git reset --hard" is destructive', () {
        expect(
          CommandWhitelist.isDestructive('zsh', ['-c', 'git reset --hard']),
          isTrue,
        );
      });
    });

    group('fork bomb patterns', () {
      test('bash -c ":(){:|:&};:" is destructive (fork bomb)', () {
        expect(
          CommandWhitelist.isDestructive('bash', ['-c', ':(){:|:&};:']),
          isTrue,
        );
      });

      test('fork bomb in args is destructive', () {
        expect(
          CommandWhitelist.isDestructive('sh', ['-c', 'f(){ f|f&};f']),
          isTrue,
        );
      });
    });
  });

  group('CommandWhitelist.getDestructiveReason', () {
    test('rm -rf / returns non-null Dutch description', () {
      final reason = CommandWhitelist.getDestructiveReason('rm', ['-rf', '/']);
      expect(reason, isNotNull);
      expect(reason, isA<String>());
      expect(reason!.isNotEmpty, isTrue);
    });

    test('ls -la returns null', () {
      expect(CommandWhitelist.getDestructiveReason('ls', ['-la']), isNull);
    });

    test('git reset --hard returns non-null description', () {
      final reason = CommandWhitelist.getDestructiveReason('git', ['reset', '--hard']);
      expect(reason, isNotNull);
    });

    test('safe command returns null', () {
      expect(CommandWhitelist.getDestructiveReason('echo', ['hello']), isNull);
    });
  });
}
