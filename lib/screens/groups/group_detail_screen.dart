import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/load_group.dart';
import '../../models/load_group_item.dart';
import '../../models/part.dart';
import '../../providers/settings_provider.dart';
import '../../providers/load_groups_provider.dart';
import '../../providers/parts_provider.dart';
import '../../widgets/add_part_section.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/furnace_summary_panel.dart';
import '../../widgets/load_group_item_tile.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  LoadGroup? _group;
  bool _isLoading = true;
  String? _error;
  bool _showAddPart = false;
  Part? _selectedPart;
  final _quantityController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _loadGroup();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadGroup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final group =
          await context.read<LoadGroupsProvider>().getGroup(widget.groupId);
      if (!mounted) {
        return;
      }
      setState(() {
        _group = group;
        _isLoading = false;
        if (group == null) {
          _error = 'Group not found';
        }
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addPartToGroup() async {
    final part = _selectedPart;
    if (part == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a part first')),
      );
      return;
    }

    final qtyText = _quantityController.text.trim().replaceAll(',', '');
    final quantity = double.tryParse(qtyText);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid quantity greater than 0')),
      );
      return;
    }

    try {
      final updated = await context.read<LoadGroupsProvider>().addPartToGroup(
            widget.groupId,
            part,
            quantity,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _group = updated;
        _selectedPart = null;
        _quantityController.text = '1';
        _showAddPart = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Part added to group')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add part: $e')),
        );
      }
    }
  }

  Future<void> _deleteItem(LoadGroupItem item) async {
    if (item.id == null) {
      return;
    }

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Remove Part',
      message: 'Remove ${item.partNo} from this group?',
      confirmLabel: 'Remove',
      isDestructive: true,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      final updated = await context
          .read<LoadGroupsProvider>()
          .deleteItemFromGroup(widget.groupId, item.id!);
      if (!mounted) {
        return;
      }
      setState(() => _group = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed ${item.partNo}')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    final partsCount = context.watch<PartsProvider>().partsCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? 'Group Detail'),
        actions: [
          if (group != null && partsCount > 0)
            IconButton(
              icon: Icon(_showAddPart ? Icons.close : Icons.add),
              tooltip: _showAddPart ? 'Close' : 'Add part',
              onPressed: () {
                setState(() => _showAddPart = !_showAddPart);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : group == null
                  ? const Center(child: Text('Group not found'))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            itemCount: group.items.length +
                                1 +
                                (_showAddPart ? 1 : 0),
                            separatorBuilder: (_, index) {
                              if (index == 0 ||
                                  (_showAddPart && index == 1)) {
                                return const SizedBox.shrink();
                              }
                              return const Divider(
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              );
                            },
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        16,
                                        16,
                                        0,
                                      ),
                                      child: Text(
                                        group.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    FurnaceSummaryPanel(
                                      totalWeightKg: group.totalWeightKg,
                                      furnaceCapacityKg: context
                                          .watch<SettingsProvider>()
                                          .furnaceCapacityKg,
                                      lineItemCount: group.items.length,
                                      compact: true,
                                    ),
                                  ],
                                );
                              }

                              if (_showAddPart && index == 1) {
                                return AddPartSection(
                                  selectedPart: _selectedPart,
                                  quantityController: _quantityController,
                                  onPartSelected: (part) {
                                    setState(() => _selectedPart = part);
                                  },
                                  onAdd: _addPartToGroup,
                                );
                              }

                              final itemIndex =
                                  index - 1 - (_showAddPart ? 1 : 0);
                              final item = group.items[itemIndex];
                              return LoadGroupItemTile(
                                item: item,
                                onRemove: () => _deleteItem(item),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: group != null && partsCount > 0 && !_showAddPart
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _showAddPart = true),
              icon: const Icon(Icons.add),
              label: const Text('Add Part'),
            )
          : null,
    );
  }
}
