import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_module/services/awareness/secret_filter.dart';

void main() {
  group('SecretFilter.filter', () {
    group('Anthropic API keys', () {
      test('sk-ant-api03 key is filtered', () {
        const input = 'export ANTHROPIC_API_KEY=sk-ant-api03-abcdefghijklmnopqrstuvwxyz';
        final result = SecretFilter.filter(input);
        expect(result, contains('[FILTERED]'));
        expect(result, isNot(contains('sk-ant-api03')));
      });

      test('inline Anthropic key in text is filtered', () {
        const key = 'sk-ant-api03-abcdefghijklmnopqrstu';
        final input = 'Key is $key and status is OK';
        final result = SecretFilter.filter(input);
        expect(result, contains('[FILTERED]'));
        expect(result, contains('Key is'));
        expect(result, contains('and status is OK'));
        expect(result, isNot(contains(key)));
      });
    });

    group('OpenAI API keys', () {
      test('sk- key with 32+ chars is filtered', () {
        const key = 'sk-abcdefghijklmnopqrstuvwxyz123456';
        final result = SecretFilter.filter('API key: $key');
        expect(result, contains('[FILTERED]'));
        expect(result, isNot(contains(key)));
      });
    });

    group('GitHub tokens', () {
      test('ghp_ personal access token is filtered', () {
        final key = 'ghp_${'a' * 36}';
        final result = SecretFilter.filter('token: $key');
        expect(result, contains('[FILTERED]'));
        expect(result, isNot(contains(key)));
      });

      test('ghs_ server token is filtered', () {
        final key = 'ghs_${'b' * 36}';
        final result = SecretFilter.filter('GITHUB_TOKEN=$key');
        expect(result, contains('[FILTERED]'));
        expect(result, isNot(contains(key)));
      });

      test('github_pat_ fine-grained PAT is filtered', () {
        final key = 'github_pat_${'c' * 82}';
        final result = SecretFilter.filter('PAT: $key');
        expect(result, contains('[FILTERED]'));
        expect(result, isNot(contains(key)));
      });
    });

    group('Generic key=value assignments', () {
      test('ANTHROPIC_API_KEY=... assignment is filtered', () {
        const input = 'ANTHROPIC_API_KEY=sk-ant-testkey123456789';
        final result = SecretFilter.filter(input);
        expect(result, contains('[FILTERED]'));
      });

      test('PASSWORD=supersecret123 is filtered', () {
        const input = 'PASSWORD=supersecret123';
        final result = SecretFilter.filter(input);
        expect(result, contains('[FILTERED]'));
        expect(result, isNot(contains('supersecret123')));
      });

      test('TOKEN= assignment is filtered', () {
        const input = 'TOKEN=myverylongtoken123';
        final result = SecretFilter.filter(input);
        expect(result, contains('[FILTERED]'));
      });

      test('SECRET= assignment is filtered', () {
        const input = 'SECRET=topsecretvalue99';
        final result = SecretFilter.filter(input);
        expect(result, contains('[FILTERED]'));
      });
    });

    group('Bearer tokens', () {
      test('JWT Bearer token is filtered', () {
        const input = 'Authorization: Bearer eyJhbGc.eyJzdWI.signature';
        final result = SecretFilter.filter(input);
        expect(result, contains('[FILTERED]'));
        expect(result, isNot(contains('eyJhbGc')));
      });
    });

    group('Basic auth', () {
      test('Authorization Basic header is filtered', () {
        const input = 'Authorization: Basic dXNlcjpwYXNzd29yZA==';
        final result = SecretFilter.filter(input);
        expect(result, contains('[FILTERED]'));
        expect(result, isNot(contains('dXNlcjpwYXNzd29yZA==')));
      });
    });

    group('Safe content', () {
      test('normal text is NOT filtered', () {
        const input = 'The build succeeded in 42 seconds';
        expect(SecretFilter.filter(input), equals(input));
      });

      test('echo hello world is NOT filtered', () {
        const input = 'echo hello world';
        expect(SecretFilter.filter(input), equals(input));
      });
    });
  });

  group('SecretFilter.containsSecrets', () {
    test('returns true for Anthropic key', () {
      expect(
        SecretFilter.containsSecrets('key=sk-ant-api03-abcdefghijklmnopqrstu'),
        isTrue,
      );
    });

    test('returns true for GitHub PAT', () {
      final key = 'ghp_${'a' * 36}';
      expect(SecretFilter.containsSecrets(key), isTrue);
    });

    test('returns false for normal output', () {
      expect(SecretFilter.containsSecrets('hello world'), isFalse);
    });

    test('returns false for short sk- that does not match', () {
      // sk- followed by fewer than 32 chars — not a valid OpenAI key
      expect(SecretFilter.containsSecrets('sk-short'), isFalse);
    });
  });
}
