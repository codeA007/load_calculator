import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/parts_provider.dart';
import '../../services/excel_import_service.dart';

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  final _importService = ExcelImportService();
  ExcelImportResult? _result;
  String? _fileName;
  bool _isLoading = false;
  bool _isImporting = false;
  String? _error;

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
      _fileName = null;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        throw StateError('Could not read the selected file.');
      }

      final parsed = await _importService.parseBytes(bytes);
      setState(() {
        _result = parsed;
        _fileName = file.name;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _import() async {
    final result = _result;
    if (result == null) {
      return;
    }

    setState(() => _isImporting = true);

    try {
      await _importService.importRows(result.rows);
      if (!mounted) {
        return;
      }
      await context.read<PartsProvider>().loadParts();

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${result.validCount} new, '
              'updated ${result.updateCount}, '
              'skipped ${result.skippedCount}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  Future<void> _shareTemplate() async {
    try {
      final byteData =
          await rootBundle.load('assets/templates/parts_template.xlsx');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/parts_template.xlsx');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Parts import template for Load Calculator',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share template: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Excel'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expected columns',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Part No (required)'),
                  const Text('Description (optional)'),
                  const Text('Weight (kg) (required)'),
                  const Text('Vendor Name (optional)'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _shareTemplate,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Download Sample Template'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isLoading ? null : _pickFile,
            icon: const Icon(Icons.folder_open),
            label: Text(_fileName ?? 'Choose Excel File (.xlsx)'),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          if (result != null) ...[
            const SizedBox(height: 24),
            Text(
              'Preview',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.add_circle_outline, size: 18),
                  label: Text('${result.validCount} new'),
                ),
                Chip(
                  avatar: const Icon(Icons.update, size: 18),
                  label: Text('${result.updateCount} updates'),
                ),
                Chip(
                  avatar: const Icon(Icons.block, size: 18),
                  label: Text('${result.skippedCount} skipped'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...result.rows.take(50).map((row) {
              final part = row.part;
              return ListTile(
                dense: true,
                leading: Icon(
                  row.status == ExcelRowStatus.skipped
                      ? Icons.warning_amber_outlined
                      : row.status == ExcelRowStatus.update
                          ? Icons.update
                          : Icons.check_circle_outline,
                  color: row.status == ExcelRowStatus.skipped
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                title: Text(
                  part?.partNo ?? 'Row ${row.rowNumber}',
                ),
                subtitle: Text(
                  row.message ??
                      '${part?.weightKg ?? '-'} kg'
                      '${part?.description != null ? ' • ${part!.description}' : ''}',
                ),
              );
            }),
            if (result.rows.length > 50)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '... and ${result.rows.length - 50} more rows',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isImporting ||
                      (result.validCount == 0 && result.updateCount == 0)
                  ? null
                  : _import,
              child: _isImporting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Import Parts'),
            ),
          ],
        ],
      ),
    );
  }
}
