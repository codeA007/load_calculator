import '../database/database_helper.dart';
import '../models/part.dart';

class PartsRepository {
  PartsRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<List<Part>> getAllParts({String? query}) {
    return _databaseHelper.getAllParts(query: query);
  }

  Future<List<Part>> searchParts(String query, {int limit = 20}) {
    return _databaseHelper.searchParts(query, limit: limit);
  }

  Future<Part?> getPartById(int id) {
    return _databaseHelper.getPartById(id);
  }

  Future<Part?> getPartByPartNo(String partNo) {
    return _databaseHelper.getPartByPartNo(partNo);
  }

  Future<int> getPartsCount() {
    return _databaseHelper.getPartsCount();
  }

  Future<Part> createPart({
    required String partNo,
    String? description,
    required double weightKg,
    String? vendorName,
  }) async {
    final trimmedPartNo = partNo.trim();
    final existing = await _databaseHelper.getPartByPartNo(trimmedPartNo);
    if (existing != null) {
      throw PartAlreadyExistsException(trimmedPartNo);
    }

    final now = DateTime.now();
    final part = Part(
      partNo: trimmedPartNo,
      description: _trimOrNull(description),
      weightKg: weightKg,
      vendorName: _trimOrNull(vendorName),
      createdAt: now,
      updatedAt: now,
    );

    final id = await _databaseHelper.insertPart(part);
    return part.copyWith(id: id);
  }

  Future<Part> updatePart({
    required int id,
    required String partNo,
    String? description,
    required double weightKg,
    String? vendorName,
  }) async {
    final existing = await _databaseHelper.getPartById(id);
    if (existing == null) {
      throw PartNotFoundException(id);
    }

    final trimmedPartNo = partNo.trim();
    final duplicate = await _databaseHelper.getPartByPartNo(trimmedPartNo);
    if (duplicate != null && duplicate.id != id) {
      throw PartAlreadyExistsException(trimmedPartNo);
    }

    final updated = existing.copyWith(
      partNo: trimmedPartNo,
      description: _trimOrNull(description),
      weightKg: weightKg,
      vendorName: _trimOrNull(vendorName),
      updatedAt: DateTime.now(),
      clearDescription: description == null || description.trim().isEmpty,
      clearVendorName: vendorName == null || vendorName.trim().isEmpty,
    );

    await _databaseHelper.updatePart(updated);
    return updated;
  }

  Future<void> deletePart(int id) async {
    await _databaseHelper.deletePart(id);
  }

  Future<void> upsertPart(Part part) {
    return _databaseHelper.upsertPart(part);
  }

  String? _trimOrNull(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class PartAlreadyExistsException implements Exception {
  PartAlreadyExistsException(this.partNo);

  final String partNo;

  @override
  String toString() => 'Part number "$partNo" already exists.';
}

class PartNotFoundException implements Exception {
  PartNotFoundException(this.id);

  final int id;

  @override
  String toString() => 'Part with id $id was not found.';
}
