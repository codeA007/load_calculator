import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _capacityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final capacity = context.read<SettingsProvider>().furnaceCapacityKg;
    _capacityController.text = _formatCapacity(capacity);
  }

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

  String _formatCapacity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final value = double.parse(
        _capacityController.text.trim().replaceAll(',', ''),
      );
      await context.read<SettingsProvider>().setFurnaceCapacityKg(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _resetDefault() async {
    _capacityController.text =
        _formatCapacity(SettingsProvider.defaultFurnaceCapacityKg);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Furnace Capacity',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Maximum weight one furnace heat can melt. '
                      'Furnace heats = total weight ÷ capacity.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _capacityController,
                      decoration: const InputDecoration(
                        labelText: 'Capacity (kg)',
                        suffixText: 'kg',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Capacity is required';
                        }
                        final parsed =
                            double.tryParse(value.replaceAll(',', ''));
                        if (parsed == null || parsed <= 0) {
                          return 'Enter a valid capacity greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: _resetDefault,
                        child: Text(
                          'Reset to default (${SettingsProvider.defaultFurnaceCapacityKg.toInt()} kg)',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
