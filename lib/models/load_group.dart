import 'load_group_item.dart';

class LoadGroup {
  const LoadGroup({
    this.id,
    required this.name,
    required this.totalWeightKg,
    required this.createdAt,
    this.items = const [],
  });

  final int? id;
  final String name;
  final double totalWeightKg;
  final DateTime createdAt;
  final List<LoadGroupItem> items;

  LoadGroup copyWith({
    int? id,
    String? name,
    double? totalWeightKg,
    DateTime? createdAt,
    List<LoadGroupItem>? items,
  }) {
    return LoadGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      totalWeightKg: totalWeightKg ?? this.totalWeightKg,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
    );
  }

  factory LoadGroup.fromMap(Map<String, dynamic> map, {List<LoadGroupItem>? items}) {
    return LoadGroup(
      id: map['id'] as int?,
      name: map['name'] as String,
      totalWeightKg: (map['total_weight_kg'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      items: items ?? const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'total_weight_kg': totalWeightKg,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
