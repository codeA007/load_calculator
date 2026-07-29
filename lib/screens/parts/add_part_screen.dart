import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/part.dart';
import '../../providers/parts_provider.dart';
import '../../repositories/parts_repository.dart';

class AddPartScreen extends StatefulWidget {
  const AddPartScreen({super.key, this.part});

  final Part? part;

  bool get isEditing => part != null;

  @override
  State<AddPartScreen> createState() => _AddPartScreenState();
}

class _AddPartScreenState extends State<AddPartScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _partNoController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _weightController;
  late final TextEditingController _vendorController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _partNoController = TextEditingController(text: widget.part?.partNo ?? '');
    _descriptionController =
        TextEditingController(text: widget.part?.description ?? '');
    _weightController = TextEditingController(
      text: widget.part != null ? widget.part!.weightKg.toString() : '',
    );
    _vendorController =
        TextEditingController(text: widget.part?.vendorName ?? '');
  }

  @override
  void dispose() {
    _partNoController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    final provider = context.read<PartsProvider>();
    final weight = double.parse(_weightController.text.trim());

    try {
      if (widget.isEditing) {
        await provider.updatePart(
          id: widget.part!.id!,
          partNo: _partNoController.text,
          description: _descriptionController.text,
          weightKg: weight,
          vendorName: _vendorController.text,
        );
      } else {
        await provider.createPart(
          partNo: _partNoController.text,
          description: _descriptionController.text,
          weightKg: weight,
          vendorName: _vendorController.text,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing ? 'Part updated' : 'Part added',
            ),
          ),
        );
      }
    } on PartAlreadyExistsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Part' : 'Add Part'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _partNoController,
              decoration: const InputDecoration(
                labelText: 'Part No *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Part number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg) *',
                border: OutlineInputBorder(),
                suffixText: 'kg',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Weight is required';
                }
                final parsed = double.tryParse(value.replaceAll(',', ''));
                if (parsed == null || parsed <= 0) {
                  return 'Enter a valid weight greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _vendorController,
              decoration: const InputDecoration(
                labelText: 'Vendor Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.isEditing ? 'Save Changes' : 'Add Part'),
            ),
          ],
        ),
      ),
    );
  }
}
