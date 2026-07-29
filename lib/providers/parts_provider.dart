import 'package:flutter/foundation.dart';

import '../models/part.dart';
import '../repositories/parts_repository.dart';

class PartsProvider extends ChangeNotifier {
  PartsProvider({PartsRepository? repository})
      : _repository = repository ?? PartsRepository();

  final PartsRepository _repository;

  List<Part> _parts = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  int _partsCount = 0;

  List<Part> get parts => List.unmodifiable(_parts);
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get partsCount => _partsCount;

  Future<void> loadParts({String? query}) async {
    _isLoading = true;
    _error = null;
    _searchQuery = query ?? _searchQuery;
    notifyListeners();

    try {
      _parts = await _repository.getAllParts(query: _searchQuery);
      _partsCount = await _repository.getPartsCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCount() async {
    _partsCount = await _repository.getPartsCount();
    notifyListeners();
  }

  Future<List<Part>> searchParts(String query) {
    return _repository.searchParts(query);
  }

  Future<Part> createPart({
    required String partNo,
    String? description,
    required double weightKg,
    String? vendorName,
  }) async {
    final part = await _repository.createPart(
      partNo: partNo,
      description: description,
      weightKg: weightKg,
      vendorName: vendorName,
    );
    await loadParts();
    return part;
  }

  Future<Part> updatePart({
    required int id,
    required String partNo,
    String? description,
    required double weightKg,
    String? vendorName,
  }) async {
    final part = await _repository.updatePart(
      id: id,
      partNo: partNo,
      description: description,
      weightKg: weightKg,
      vendorName: vendorName,
    );
    await loadParts();
    return part;
  }

  Future<void> deletePart(int id) async {
    await _repository.deletePart(id);
    await loadParts();
  }
}
