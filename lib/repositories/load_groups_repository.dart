import '../database/database_helper.dart';
import '../models/calc_line_item.dart';
import '../models/load_group.dart';
import '../models/load_group_item.dart';
import '../models/part.dart';
import '../utils/group_name_generator.dart';

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

  List<LoadGroupItem> _toGroupItems(List<CalcLineItem> lineItems) {
    return lineItems
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
  }

  List<LoadGroupItem> itemsFromPart(Part part, double quantity) {
    return [
      LoadGroupItem(
        partId: part.id,
        partNo: part.partNo,
        description: part.description,
        unitWeightKg: part.weightKg,
        quantity: quantity,
        lineWeightKg: part.weightKg * quantity,
      ),
    ];
  }

  Future<LoadGroup> saveGroup(List<CalcLineItem> lineItems) async {
    if (lineItems.isEmpty) {
      throw ArgumentError('Cannot save an empty group');
    }

    final now = DateTime.now();
    final existing = await _databaseHelper.getAllLoadGroups();
    final name = GroupNameGenerator.uniqueName(
      now,
      existing.map((group) => group.name),
    );

    final items = _toGroupItems(lineItems);
    final totalWeight =
        items.fold(0.0, (sum, item) => sum + item.lineWeightKg);

    final group = LoadGroup(
      name: name,
      totalWeightKg: totalWeight,
      createdAt: now,
      items: items,
    );

    final id = await _databaseHelper.insertLoadGroup(group);
    return group.copyWith(id: id, items: items);
  }

  Future<LoadGroup> addPartsToGroup(
    int groupId,
    Part part,
    double quantity,
  ) async {
    final group = await _databaseHelper.getLoadGroupById(groupId);
    if (group == null) {
      throw StateError('Group not found');
    }

    final items = itemsFromPart(part, quantity);
    await _databaseHelper.addItemsToLoadGroup(groupId, items);

    final updated = await _databaseHelper.getLoadGroupById(groupId);
    return updated!;
  }

  Future<LoadGroup> deleteItemFromGroup(int groupId, int itemId) async {
    final group = await _databaseHelper.getLoadGroupById(groupId);
    if (group == null) {
      throw StateError('Group not found');
    }

    await _databaseHelper.deleteLoadGroupItem(itemId, groupId);

    final updated = await _databaseHelper.getLoadGroupById(groupId);
    return updated!;
  }

  Future<void> deleteGroup(int id) {
    return _databaseHelper.deleteLoadGroup(id);
  }
}
