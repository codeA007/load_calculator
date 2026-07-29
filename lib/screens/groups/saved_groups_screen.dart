import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/load_group.dart';
import '../../providers/settings_provider.dart';
import '../../providers/load_groups_provider.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/empty_state_view.dart';
import '../../widgets/load_group_item_tile.dart';
import 'group_detail_screen.dart';

class SavedGroupsScreen extends StatefulWidget {
  const SavedGroupsScreen({super.key});

  @override
  State<SavedGroupsScreen> createState() => _SavedGroupsScreenState();
}

class _SavedGroupsScreenState extends State<SavedGroupsScreen> {
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
    final furnaceCapacity =
        context.watch<SettingsProvider>().furnaceCapacityKg;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Groups'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : provider.groups.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.folder_open_outlined,
                      title: 'No saved groups yet',
                      message:
                          'Use the Furnace Calculator and tap Save Group to store loads here.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: provider.groups.length,
                      separatorBuilder: (_, _) => const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      itemBuilder: (context, index) {
                        final group = provider.groups[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(
                            group.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(formatGroupSubtitle(
                            group,
                            furnaceCapacity,
                          )),
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
