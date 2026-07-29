import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/load_group.dart';
import '../../providers/load_groups_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadGroup();
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

  @override
  Widget build(BuildContext context) {
    final group = _group;

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? 'Group Detail'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : group == null
                  ? const Center(child: Text('Group not found'))
                  : ListView.separated(
                      itemCount: group.items.length + 1,
                      separatorBuilder: (_, index) {
                        if (index == 0) {
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
                          return LoadGroupHeader(group: group);
                        }
                        return LoadGroupItemTile(item: group.items[index - 1]);
                      },
                    ),
    );
  }
}
