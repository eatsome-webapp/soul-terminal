// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agentic_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AgenticSession)
final agenticSessionProvider = AgenticSessionProvider._();

final class AgenticSessionProvider
    extends $NotifierProvider<AgenticSession, AgenticSessionState> {
  AgenticSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agenticSessionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agenticSessionHash();

  @$internal
  @override
  AgenticSession create() => AgenticSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AgenticSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AgenticSessionState>(value),
    );
  }
}

String _$agenticSessionHash() => r'e6b87904e53759cdffbf21afc968a7118824cbaa';

abstract class _$AgenticSession extends $Notifier<AgenticSessionState> {
  AgenticSessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AgenticSessionState, AgenticSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AgenticSessionState, AgenticSessionState>,
              AgenticSessionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
