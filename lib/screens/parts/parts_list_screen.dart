import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/parts_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import 'add_part_screen.dart';
import 'import_excel_screen.dart';

class PartsListScreen extends StatefulWidget {
  const PartsListScreen({super.key});

  @override
  State<PartsListScreen> createState() => _PartsListScreenState();
}

class _PartsListScreenState extends State<PartsListScreen> {
  final _searchController = TextEditingController();
  static final _weightFormat = NumberFormat('#,##0.###');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PartsProvider>().loadParts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deletePart(int id, String partNo) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Part',
      message: 'Delete part "$partNo"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await context.read<PartsProvider>().deletePart(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted $partNo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PartsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parts Library'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search parts...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.loadParts(query: '');
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => provider.loadParts(query: value),
            ),
          ),
          if (provider.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.error != null)
            Expanded(
              child: Center(child: Text(provider.error!)),
            )
          else if (provider.parts.isEmpty)
            Expanded(
              child: EmptyStateView(
                icon: Icons.inventory_2_outlined,
                title: provider.searchQuery.isEmpty
                    ? 'No parts yet'
                    : 'No matching parts',
                message: provider.searchQuery.isEmpty
                    ? 'Add a part manually or import from Excel.'
                    : 'Try a different search term.',
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: provider.parts.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final part = provider.parts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      part.partNo,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (part.description != null &&
                            part.description!.isNotEmpty)
                          Text(part.description!),
                        Text(
                          '${_weightFormat.format(part.weightKg)} kg'
                          '${part.vendorName != null ? ' • ${part.vendorName}' : ''}',
                        ),
                      ],
                    ),
                    isThreeLine: part.description != null &&
                        part.description!.isNotEmpty,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AddPartScreen(part: part),
                            ),
                          );
                        } else if (value == 'delete') {
                          await _deletePart(part.id!, part.partNo);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline),
                            title: Text('Delete'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'import',
            onPressed: () async {
              final partsProvider = context.read<PartsProvider>();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ImportExcelScreen(),
                ),
              );
              if (!mounted) {
                return;
              }
              await partsProvider.loadParts(
                query: _searchController.text,
              );
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Import Excel'),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () async {
              final partsProvider = context.read<PartsProvider>();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddPartScreen(),
                ),
              );
              if (!mounted) {
                return;
              }
              await partsProvider.loadParts(
                query: _searchController.text,
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Part'),
          ),
        ],
      ),
    );
  }
}
