class Part {
  const Part({
    this.id,
    required this.partNo,
    this.description,
    required this.weightKg,
    this.vendorName,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String partNo;
  final String? description;
  final double weightKg;
  final String? vendorName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Part copyWith({
    int? id,
    String? partNo,
    String? description,
    double? weightKg,
    String? vendorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearVendorName = false,
  }) {
    return Part(
      id: id ?? this.id,
      partNo: partNo ?? this.partNo,
      description: clearDescription ? null : (description ?? this.description),
      weightKg: weightKg ?? this.weightKg,
      vendorName:
          clearVendorName ? null : (vendorName ?? this.vendorName),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Part.fromMap(Map<String, dynamic> map) {
    return Part(
      id: map['id'] as int?,
      partNo: map['part_no'] as String,
      description: map['description'] as String?,
      weightKg: (map['weight_kg'] as num).toDouble(),
      vendorName: map['vendor_name'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'part_no': partNo,
      'description': description,
      'weight_kg': weightKg,
      'vendor_name': vendorName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayLabel {
    if (description != null && description!.trim().isNotEmpty) {
      return '$partNo — ${description!.trim()}';
    }
    return partNo;
  }
}
