import '../database/database_helper.dart';
import '../models/calc_line_item.dart';
import '../models/load_group.dart';
import '../models/load_group_item.dart';

class LoadGroupsRepository {
  LoadGroupsRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<List<LoadGroup>> getAllGroups() {
    return _databaseHelper.getAllLoadGroups();
  }

  Future<LoadGroup?> getGroup(int id) {
    return _databaseHelper.getLoadGroupById(id);
  }

  Future<int> getGroupsCount() {
    return _databaseHelper.getLoadGroupsCount();
  }

  Future<LoadGroup> saveGroup(String name, List<CalcLineItem> lineItems) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Group name cannot be empty');
    }
    if (lineItems.isEmpty) {
      throw ArgumentError('Cannot save an empty group');
    }

    final now = DateTime.now();
    final items = lineItems
        .map(
          (line) => LoadGroupItem(
            partId: line.part.id,
            partNo: line.part.partNo,
            description: line.part.description,
            unitWeightKg: line.part.weightKg,
            quantity: line.quantity,
            lineWeightKg: line.lineWeight,
          ),
        )
        .toList();

    final totalWeight =
        items.fold(0.0, (sum, item) => sum + item.lineWeightKg);

    final group = LoadGroup(
      name: trimmedName,
      totalWeightKg: totalWeight,
      createdAt: now,
      items: items,
    );

    final id = await _databaseHelper.insertLoadGroup(group);
    return group.copyWith(id: id, items: items);
  }

  Future<void> deleteGroup(int id) {
    return _databaseHelper.deleteLoadGroup(id);
  }
}
