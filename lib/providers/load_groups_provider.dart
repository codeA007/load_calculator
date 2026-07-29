import 'package:flutter/foundation.dart';

import '../models/calc_line_item.dart';
import '../models/load_group.dart';
import '../repositories/load_groups_repository.dart';

class LoadGroupsProvider extends ChangeNotifier {
  LoadGroupsProvider({LoadGroupsRepository? repository})
      : _repository = repository ?? LoadGroupsRepository();

  final LoadGroupsRepository _repository;

  List<LoadGroup> _groups = [];
  bool _isLoading = false;
  String? _error;
  int _groupsCount = 0;

  List<LoadGroup> get groups => List.unmodifiable(_groups);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get groupsCount => _groupsCount;

  Future<void> loadGroups() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = await _repository.getAllGroups();
      _groupsCount = await _repository.getGroupsCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCount() async {
    _groupsCount = await _repository.getGroupsCount();
    notifyListeners();
  }

  Future<LoadGroup?> getGroup(int id) {
    return _repository.getGroup(id);
  }

  Future<LoadGroup> saveGroup(String name, List<CalcLineItem> lineItems) async {
    final group = await _repository.saveGroup(name, lineItems);
    await loadGroups();
    return group;
  }

  Future<void> deleteGroup(int id) async {
    await _repository.deleteGroup(id);
    await loadGroups();
  }
}
