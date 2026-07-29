import 'package:flutter_test/flutter_test.dart';
import 'package:load_calculator/utils/group_name_generator.dart';

void main() {
  test('fromDateTime formats readable date name', () {
    final name = GroupNameGenerator.fromDateTime(
      DateTime(2026, 7, 30, 13, 47),
    );
    expect(name, contains('Jul'));
    expect(name, contains('2026'));
  });

  test('uniqueName appends suffix when name exists', () {
    final date = DateTime(2026, 7, 30, 13, 47);
    final base = GroupNameGenerator.fromDateTime(date);

    expect(
      GroupNameGenerator.uniqueName(date, [base]),
      '$base (2)',
    );
  });
}
