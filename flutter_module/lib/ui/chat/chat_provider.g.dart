// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages chat message state, streaming lifecycle, persistence, and offline queueing.
///
/// Handles sending messages, streaming responses from Claude,
/// error classification, stop/retry actions, and database persistence.

@ProviderFor(ChatNotifier)
final chatProvider = ChatNotifierFamily._();

/// Manages chat message state, streaming lifecycle, persistence, and offline queueing.
///
/// Handles sending messages, streaming responses from Claude,
/// error classification, stop/retry actions, and database persistence.
final class ChatNotifierProvider
    extends $NotifierProvider<ChatNotifier, ChatState> {
  /// Manages chat message state, streaming lifecycle, persistence, and offline queueing.
  ///
  /// Handles sending messages, streaming responses from Claude,
  /// error classification, stop/retry actions, and database persistence.
  ChatNotifierProvider._({
    required ChatNotifierFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'chatProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chatNotifierHash();

  @override
  String toString() {
    return r'chatProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChatNotifier create() => ChatNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChatState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChatState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ChatNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chatNotifierHash() => r'ae0c5279e2a4c7c06309a89daf37cbf7c307f8ad';

/// Manages chat message state, streaming lifecycle, persistence, and offline queueing.
///
/// Handles sending messages, streaming responses from Claude,
/// error classification, stop/retry actions, and database persistence.

final class ChatNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          ChatNotifier,
          ChatState,
          ChatState,
          ChatState,
          String?
        > {
  ChatNotifierFamily._()
    : super(
        retry: null,
        name: r'chatProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Manages chat message state, streaming lifecycle, persistence, and offline queueing.
  ///
  /// Handles sending messages, streaming responses from Claude,
  /// error classification, stop/retry actions, and database persistence.

  ChatNotifierProvider call(String? conversationId) =>
      ChatNotifierProvider._(argument: conversationId, from: this);

  @override
  String toString() => r'chatProvider';
}

/// Manages chat message state, streaming lifecycle, persistence, and offline queueing.
///
/// Handles sending messages, streaming responses from Claude,
/// error classification, stop/retry actions, and database persistence.

abstract class _$ChatNotifier extends $Notifier<ChatState> {
  late final _$args = ref.$arg as String?;
  String? get conversationId => _$args;

  ChatState build(String? conversationId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChatState, ChatState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChatState, ChatState>,
              ChatState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
