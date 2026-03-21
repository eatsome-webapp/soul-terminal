// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intervention_config.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(interventionConfig)
final interventionConfigProvider = InterventionConfigProvider._();

final class InterventionConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<InterventionConfig>,
          InterventionConfig,
          FutureOr<InterventionConfig>
        >
    with
        $FutureModifier<InterventionConfig>,
        $FutureProvider<InterventionConfig> {
  InterventionConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'interventionConfigProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$interventionConfigHash();

  @$internal
  @override
  $FutureProviderElement<InterventionConfig> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InterventionConfig> create(Ref ref) {
    return interventionConfig(ref);
  }
}

String _$interventionConfigHash() =>
    r'358c5c531001e39bd3d4b62ae798af0bf7527c41';
