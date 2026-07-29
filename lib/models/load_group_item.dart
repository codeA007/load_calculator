class LoadGroupItem {
  const LoadGroupItem({
    this.id,
    this.groupId,
    this.partId,
    required this.partNo,
    this.description,
    required this.unitWeightKg,
    required this.quantity,
    required this.lineWeightKg,
  });

  final int? id;
  final int? groupId;
  final int? partId;
  final String partNo;
  final String? description;
  final double unitWeightKg;
  final double quantity;
  final double lineWeightKg;

  LoadGroupItem copyWith({
    int? id,
    int? groupId,
    int? partId,
    String? partNo,
    String? description,
    double? unitWeightKg,
    double? quantity,
    double? lineWeightKg,
  }) {
    return LoadGroupItem(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      partId: partId ?? this.partId,
      partNo: partNo ?? this.partNo,
      description: description ?? this.description,
      unitWeightKg: unitWeightKg ?? this.unitWeightKg,
      quantity: quantity ?? this.quantity,
      lineWeightKg: lineWeightKg ?? this.lineWeightKg,
    );
  }

  factory LoadGroupItem.fromMap(Map<String, dynamic> map) {
    return LoadGroupItem(
      id: map['id'] as int?,
      groupId: map['group_id'] as int?,
      partId: map['part_id'] as int?,
      partNo: map['part_no'] as String,
      description: map['description'] as String?,
      unitWeightKg: (map['unit_weight_kg'] as num).toDouble(),
      quantity: (map['quantity'] as num).toDouble(),
      lineWeightKg: (map['line_weight_kg'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      'part_id': partId,
      'part_no': partNo,
      'description': description,
      'unit_weight_kg': unitWeightKg,
      'quantity': quantity,
      'line_weight_kg': lineWeightKg,
    };
  }
}
