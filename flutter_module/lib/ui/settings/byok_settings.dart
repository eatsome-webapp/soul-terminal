import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/di/providers.dart';
import '../../services/ai/cost_tracker.dart';
import '../../services/database/daos/settings_dao.dart';

/// BYOK (Bring Your Own Key) settings section.
/// Provides API key input, validation, cost display, and budget config.
class ByokSettings extends ConsumerStatefulWidget {
  const ByokSettings({super.key});

  @override
  ConsumerState<ByokSettings> createState() => _ByokSettingsState();
}

enum _ValidationState { idle, validating, valid, error }

class _ByokSettingsState extends ConsumerState<ByokSettings> {
  final _keyController = TextEditingController();
  final _dailyBudgetController = TextEditingController(text: '5.00');
  final _monthlyBudgetController = TextEditingController(text: '50.00');
  _ValidationState _validationState = _ValidationState.idle;
  String? _errorMessage;
  bool _hasKey = false;
  CostSummary? _costSummary;
  bool _budgetWarningEnabled = true;

  @override
  void initState() {
    super.initState();
    _checkExistingKey();
    _loadCostData();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _dailyBudgetController.dispose();
    _monthlyBudgetController.dispose();
    super.dispose();
  }

  Future<void> _loadCostData() async {
    final costTracker = ref.read(costTrackerProvider);
    final settingsDao = ref.read(settingsDaoProvider);
    final summary = await costTracker.getCostSummary();
    final warningEnabled =
        await settingsDao.getBool(SettingsKeys.budgetWarningEnabled) ?? true;

    if (mounted) {
      setState(() {
        _costSummary = summary;
        _budgetWarningEnabled = warningEnabled;
        _dailyBudgetController.text = summary.dailyBudget.toStringAsFixed(2);
        _monthlyBudgetController.text = summary.monthlyBudget.toStringAsFixed(2);
      });
    }
  }

  Future<void> _saveBudget(String key, String value) async {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed > 0) {
      final settingsDao = ref.read(settingsDaoProvider);
      await settingsDao.setDouble(key, parsed);
      await _loadCostData(); // Refresh display
    }
  }

  Future<void> _checkExistingKey() async {
    final apiKeyService = ref.read(apiKeyServiceProvider);
    final hasKey = await apiKeyService.hasAnthropicKey();
    if (mounted) {
      setState(() {
        _hasKey = hasKey;
        if (hasKey) _validationState = _ValidationState.valid;
      });
    }
  }

  Future<void> _validateAndSave() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;

    setState(() {
      _validationState = _ValidationState.validating;
      _errorMessage = null;
    });

    final apiKeyService = ref.read(apiKeyServiceProvider);
    final error = await apiKeyService.validateAndSaveKey(key);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _validationState = _ValidationState.error;
        _errorMessage = error;
      });
    } else {
      // Update the app-wide API key notifier
      ref.read(apiKeyNotifierProvider.notifier).setKey(key);
      setState(() {
        _validationState = _ValidationState.valid;
        _hasKey = true;
        _errorMessage = null;
      });
      _keyController.clear();
    }
  }

  Future<void> _deleteKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Key verwijderen'),
        content: const Text(
          'Weet je zeker dat je je API key wilt verwijderen? '
          'SOUL kan daarna niet meer met Claude communiceren.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final apiKeyService = ref.read(apiKeyServiceProvider);
      await apiKeyService.deleteAnthropicKey();
      ref.read(apiKeyNotifierProvider.notifier).setKey('');
      if (mounted) {
        setState(() {
          _hasKey = false;
          _validationState = _ValidationState.idle;
        });
      }
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _keyController.text = data!.text!.trim();
    }
  }

  Future<void> _openConsole() async {
    final uri = Uri.parse('https://console.anthropic.com/settings/keys');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('API Key', style: textTheme.titleMedium),
        ),

        // Key status
        if (_hasKey && _validationState == _ValidationState.valid)
          ListTile(
            leading: Icon(Icons.check_circle, color: colorScheme.primary),
            title: const Text('Key is geldig'),
            trailing: TextButton(
              onPressed: _deleteKey,
              child: Text(
                'Key verwijderen',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
          ),

        // Key input (show when no key or replacing)
        if (!_hasKey) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _keyController,
              obscureText: true,
              maxLines: 1,
              decoration: InputDecoration(
                labelText: 'Anthropic API Key',
                hintText: 'sk-ant-api03-...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.content_paste),
                  onPressed: _pasteFromClipboard,
                  tooltip: 'Plakken',
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Console link
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              onPressed: _openConsole,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Get API key at console.anthropic.com'),
            ),
          ),
          const SizedBox(height: 8),

          // Validate button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _validationState == _ValidationState.validating
                    ? null
                    : _validateAndSave,
                child: _validationState == _ValidationState.validating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Valideer & Bewaar'),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Validation feedback
          if (_validationState == _ValidationState.validating)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Valideren...'),
                ],
              ),
            ),
          if (_validationState == _ValidationState.error &&
              _errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                style:
                    textTheme.bodySmall?.copyWith(color: colorScheme.error),
              ),
            ),
        ],

        const Divider(),

        // Cost display (only when key exists)
        if (_hasKey && _costSummary != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Kosten', style: textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Vandaag: \$${_costSummary!.todayCost.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: _costSummary!.isDailyBudgetExceeded
                        ? colorScheme.error
                        : null,
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  'Deze maand: \$${_costSummary!.monthCost.toStringAsFixed(2)}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: _costSummary!.isMonthlyBudgetExceeded
                        ? colorScheme.error
                        : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Budget config
          ListTile(
            title: const Text('Dagbudget'),
            trailing: SizedBox(
              width: 80,
              child: TextField(
                controller: _dailyBudgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  prefixText: '\$',
                  isDense: true,
                ),
                onSubmitted: (value) => _saveBudget(SettingsKeys.dailyBudgetUsd, value),
              ),
            ),
          ),
          ListTile(
            title: const Text('Maandbudget'),
            trailing: SizedBox(
              width: 80,
              child: TextField(
                controller: _monthlyBudgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.end,
                decoration: const InputDecoration(
                  prefixText: '\$',
                  isDense: true,
                ),
                onSubmitted: (value) => _saveBudget(SettingsKeys.monthlyBudgetUsd, value),
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Budgetwaarschuwing'),
            value: _budgetWarningEnabled,
            onChanged: (enabled) async {
              setState(() => _budgetWarningEnabled = enabled);
              final settingsDao = ref.read(settingsDaoProvider);
              await settingsDao.setBool(SettingsKeys.budgetWarningEnabled, enabled);
            },
          ),
          const Divider(),
        ],

        // Empty state when no cost data
        if (_hasKey && _costSummary == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Nog geen kosten — begin een gesprek om gebruik te zien',
              style: textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
