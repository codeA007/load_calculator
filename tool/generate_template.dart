import 'dart:io';

import 'package:excel/excel.dart';

void main() {
  final excel = Excel.createExcel();
  final sheet = excel[excel.getDefaultSheet()!];

  sheet.appendRow([
    TextCellValue('Part No'),
    TextCellValue('Description'),
    TextCellValue('Weight (kg)'),
    TextCellValue('Vendor Name'),
  ]);
  sheet.appendRow([
    TextCellValue('ABC-001'),
    TextCellValue('Sample bracket'),
    DoubleCellValue(2.5),
    TextCellValue('Acme Corp'),
  ]);
  sheet.appendRow([
    TextCellValue('XYZ-200'),
    TextCellValue('Mounting plate'),
    DoubleCellValue(1.2),
    TextCellValue('Global Parts'),
  ]);

  final bytes = excel.encode();
  if (bytes == null) {
    throw StateError('Failed to encode template workbook.');
  }

  final file = File('assets/templates/parts_template.xlsx');
  file.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
  stdout.writeln('Wrote ${file.path}');
}
