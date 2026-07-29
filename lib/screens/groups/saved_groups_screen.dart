import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/load_group.dart';
import '../../providers/load_groups_provider.dart';
import '../../widgets/confirm_dialog.dart';
import 'group_detail_screen.dart';

class SavedGroupsScreen extends StatefulWidget {
  const SavedGroupsScreen({super.key});

  @override
  State<SavedGroupsScreen> createState() => _SavedGroupsScreenState();
}

class _SavedGroupsScreenState extends State<SavedGroupsScreen> {
  static final _weightFormat = NumberFormat('#,##0.###');
  static final _dateFormat = DateFormat('d MMM yyyy, h:mm a');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoadGroupsProvider>().loadGroups();
    });
  }

  Future<void> _deleteGroup(LoadGroup group) async {
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete Group',
      message: 'Delete "${group.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await context.read<LoadGroupsProvider>().deleteGroup(group.id!);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted "${group.name}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LoadGroupsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Groups'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.groups.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.folder_open_outlined,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No saved groups yet',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Calculate a load and tap Save Group to store it here.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: provider.groups.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final group = provider.groups[index];
                        return ListTile(
                          title: Text(group.name),
                          subtitle: Text(
                            '${_dateFormat.format(group.createdAt)}  •  '
                            '${_weightFormat.format(group.totalWeightKg)} kg',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'delete') {
                                await _deleteGroup(group);
                              }
                            },
                            itemBuilder: (context) => [
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
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    GroupDetailScreen(groupId: group.id!),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
