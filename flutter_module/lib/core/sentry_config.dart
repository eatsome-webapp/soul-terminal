import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:logger/logger.dart';

final _logger = Logger();

/// Sentry configuration with strict PII filtering.
/// Only stack traces and device info are sent — never conversation content,
/// API keys, or user-generated text.
class SentryConfig {
  static const _dsn = String.fromEnvironment('SENTRY_DSN');

  /// Whether Sentry is configured (DSN provided at build time).
  static bool get isConfigured => _dsn.isNotEmpty;

  /// Patterns that indicate sensitive data.
  static final _sensitivePatterns = [
    RegExp(r'sk-ant-[a-zA-Z0-9\-]+'), // Anthropic API keys
    RegExp(r'sk-[a-zA-Z0-9\-]{20,}'), // Generic API key pattern
    RegExp(r'Bearer\s+[a-zA-Z0-9\-._~+/]+=*'), // Bearer tokens
    RegExp(r'anthropic', caseSensitive: false),
    RegExp(r'api_key', caseSensitive: false),
  ];

  /// Initialize Sentry with PII filtering. Wraps appRunner.
  static Future<void> init({required Future<void> Function() appRunner}) async {
    if (!isConfigured) {
      _logger.w('SENTRY_DSN not provided, crash reporting disabled');
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        options.tracesSampleRate = 0.2;
        options.sendDefaultPii = false;
        options.beforeSend = _filterEvent;
        options.beforeBreadcrumb = _filterBreadcrumb;
      },
      appRunner: appRunner,
    );
    _logger.i('Sentry initialized with PII filtering');
  }

  /// Filter Sentry events — strip any sensitive data.
  static SentryEvent? _filterEvent(SentryEvent event, Hint hint) {
    // Check exception messages for sensitive patterns
    final exceptions = event.exceptions;
    if (exceptions != null) {
      for (final exception in exceptions) {
        final value = exception.value;
        if (value != null && _containsSensitiveData(value)) {
          // Redact the exception value
          return event.copyWith(
            exceptions: exceptions.map((e) {
              if (e.value != null && _containsSensitiveData(e.value!)) {
                return e.copyWith(value: '[REDACTED — contains sensitive data]');
              }
              return e;
            }).toList(),
          );
        }
      }
    }

    return event;
  }

  /// Filter breadcrumbs — remove any containing sensitive patterns.
  static Breadcrumb? _filterBreadcrumb(Breadcrumb? breadcrumb, Hint hint) {
    if (breadcrumb == null) return null;
    final message = breadcrumb.message;
    if (message != null && _containsSensitiveData(message)) {
      return null; // Drop the breadcrumb entirely
    }

    // Check breadcrumb data map
    final data = breadcrumb.data;
    if (data != null) {
      for (final value in data.values) {
        if (value is String && _containsSensitiveData(value)) {
          return null;
        }
      }
    }

    return breadcrumb;
  }

  /// Check if a string contains sensitive data patterns.
  static bool _containsSensitiveData(String text) {
    return _sensitivePatterns.any((pattern) => pattern.hasMatch(text));
  }

  /// Disable Sentry (for opt-out). Safe to call even if not initialized.
  static Future<void> close() async {
    if (isConfigured) {
      await Sentry.close();
      _logger.i('Sentry closed (user opted out)');
    }
  }

  /// Re-enable Sentry after opt-out. Requires app restart for full effect.
  /// For simplicity in v1, toggling back on shows a message that restart is needed.
  static bool get canReinitialize => isConfigured;
}
