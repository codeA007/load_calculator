import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

import '../models/part.dart';
import '../repositories/parts_repository.dart';

enum ExcelRowStatus { valid, skipped, update }

class ParsedExcelRow {
  const ParsedExcelRow({
    required this.rowNumber,
    required this.status,
    this.part,
    this.message,
  });

  final int rowNumber;
  final ExcelRowStatus status;
  final Part? part;
  final String? message;
}

class ExcelImportResult {
  const ExcelImportResult({
    required this.rows,
    required this.validCount,
    required this.skippedCount,
    required this.updateCount,
  });

  final List<ParsedExcelRow> rows;
  final int validCount;
  final int skippedCount;
  final int updateCount;
}

class ExcelImportService {
  ExcelImportService({PartsRepository? repository})
      : _repository = repository ?? PartsRepository();

  final PartsRepository _repository;

  Future<ExcelImportResult> parseBytes(Uint8List bytes) async {
    final sheetRows = _decodeSheetRows(bytes);
    if (sheetRows.isEmpty) {
      throw FormatException('The Excel worksheet is empty.');
    }

    final headerRow = sheetRows.first;
    final columnMap = _mapColumns(headerRow);

    if (columnMap.partNoIndex == null || columnMap.weightIndex == null) {
      throw FormatException(
        'Missing required columns. Expected "Part No" and "Weight (kg)".',
      );
    }

    final parsedRows = <ParsedExcelRow>[];
    var validCount = 0;
    var skippedCount = 0;
    var updateCount = 0;

    for (var i = 1; i < sheetRows.length; i++) {
      final row = sheetRows[i];
      final rowNumber = i + 1;

      if (_isEmptyRow(row)) {
        continue;
      }

      final partNo = _cellText(row, columnMap.partNoIndex);
      final description = _cellText(row, columnMap.descriptionIndex);
      final weightText = _cellText(row, columnMap.weightIndex);
      final vendorName = _cellText(row, columnMap.vendorIndex);

      if (partNo == null || partNo.isEmpty) {
        skippedCount++;
        parsedRows.add(
          ParsedExcelRow(
            rowNumber: rowNumber,
            status: ExcelRowStatus.skipped,
            message: 'Missing part number',
          ),
        );
        continue;
      }

      final weight = _parseWeight(weightText);
      if (weight == null || weight <= 0) {
        skippedCount++;
        parsedRows.add(
          ParsedExcelRow(
            rowNumber: rowNumber,
            status: ExcelRowStatus.skipped,
            message: 'Invalid weight',
          ),
        );
        continue;
      }

      final existing = await _repository.getPartByPartNo(partNo);
      final now = DateTime.now();
      final part = Part(
        id: existing?.id,
        partNo: partNo,
        description: description,
        weightKg: weight,
        vendorName: vendorName,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (existing != null) {
        updateCount++;
        parsedRows.add(
          ParsedExcelRow(
            rowNumber: rowNumber,
            status: ExcelRowStatus.update,
            part: part,
          ),
        );
      } else {
        validCount++;
        parsedRows.add(
          ParsedExcelRow(
            rowNumber: rowNumber,
            status: ExcelRowStatus.valid,
            part: part,
          ),
        );
      }
    }

    return ExcelImportResult(
      rows: parsedRows,
      validCount: validCount,
      skippedCount: skippedCount,
      updateCount: updateCount,
    );
  }

  Future<void> importRows(List<ParsedExcelRow> rows) async {
    for (final row in rows) {
      final part = row.part;
      if (part == null) {
        continue;
      }
      if (row.status == ExcelRowStatus.skipped) {
        continue;
      }
      await _repository.upsertPart(part);
    }
  }

  static Excel createTemplateWorkbook() {
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet()!;
    final sheet = excel[defaultSheet];

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

    return excel;
  }

  /// Reads the first worksheet using a tolerant parser (handles broken style
  /// metadata that breaks the `excel` package), then falls back to `excel`.
  static List<List<dynamic>> _decodeSheetRows(Uint8List bytes) {
    Object? primaryError;
    try {
      return _rowsFromSpreadsheetDecoder(bytes);
    } catch (e) {
      primaryError = e;
    }

    try {
      return _rowsFromExcelPackage(bytes);
    } catch (_) {
      throw FormatException(
        'Could not read this Excel file. Try opening it in Excel or '
        'Google Sheets and saving a fresh .xlsx copy, or use the app template.\n'
        '$primaryError',
      );
    }
  }

  static List<List<dynamic>> _rowsFromSpreadsheetDecoder(Uint8List bytes) {
    final decoder = SpreadsheetDecoder.decodeBytes(bytes);
    if (decoder.tables.isEmpty) {
      throw FormatException('The Excel file has no worksheets.');
    }

    final table = decoder.tables.values.first;
    if (table.rows.isEmpty) {
      throw FormatException('The Excel worksheet is empty.');
    }

    return table.rows
        .map((row) => row.map<dynamic>((cell) => cell).toList())
        .toList();
  }

  static List<List<dynamic>> _rowsFromExcelPackage(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) {
      throw FormatException('The Excel file has no worksheets.');
    }

    final sheet = excel.tables.values.first;
    if (sheet.rows.isEmpty) {
      throw FormatException('The Excel worksheet is empty.');
    }

    return sheet.rows
        .map(
          (row) => row.map<dynamic>((cell) => cell).toList(),
        )
        .toList();
  }
}

class _ColumnMap {
  const _ColumnMap({
    this.partNoIndex,
    this.descriptionIndex,
    this.weightIndex,
    this.vendorIndex,
  });

  final int? partNoIndex;
  final int? descriptionIndex;
  final int? weightIndex;
  final int? vendorIndex;
}

_ColumnMap _mapColumns(List<dynamic> headerRow) {
  int? partNoIndex;
  int? descriptionIndex;
  int? weightIndex;
  int? vendorIndex;

  for (var i = 0; i < headerRow.length; i++) {
    final header = _normalizeHeader(_cellTextFromValue(headerRow[i]));
    if (header == null) {
      continue;
    }

    if (_matchesAny(header, ['part no', 'part number', 'partno', 'part code'])) {
      partNoIndex = i;
    } else if (_matchesAny(header, ['description', 'part desc', 'desc'])) {
      descriptionIndex = i;
    } else if (_matchesAny(header, ['weight', 'weight kg', 'weight (kg)', 'wt'])) {
      weightIndex = i;
    } else if (_matchesAny(header, ['vendor', 'vendor name', 'supplier'])) {
      vendorIndex = i;
    }
  }

  return _ColumnMap(
    partNoIndex: partNoIndex,
    descriptionIndex: descriptionIndex,
    weightIndex: weightIndex,
    vendorIndex: vendorIndex,
  );
}

bool _matchesAny(String value, List<String> options) {
  return options.any((option) => value.contains(option));
}

String? _normalizeHeader(String? value) {
  if (value == null) {
    return null;
  }
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9 ]'), ' ').trim();
}

bool _isEmptyRow(List<dynamic> row) {
  return row.every((cell) {
    final text = _cellTextFromValue(cell);
    return text == null || text.isEmpty;
  });
}

String? _cellText(List<dynamic> row, int? index) {
  if (index == null || index >= row.length) {
    return null;
  }
  return _cellTextFromValue(row[index]);
}

String? _cellTextFromValue(dynamic cell) {
  if (cell == null) {
    return null;
  }

  if (cell is Data) {
    return _cellTextFromExcelData(cell);
  }

  if (cell is String) {
    final text = cell.trim();
    return text.isEmpty ? null : text;
  }
  if (cell is num) {
    return cell.toString();
  }
  if (cell is bool) {
    return cell.toString();
  }

  final text = cell.toString().trim();
  return text.isEmpty ? null : text;
}

String? _cellTextFromExcelData(Data cell) {
  final value = cell.value;
  if (value == null) {
    return null;
  }

  if (value is TextCellValue) {
    final text = value.value.text?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
  if (value is IntCellValue) {
    return value.value.toString();
  }
  if (value is DoubleCellValue) {
    return value.value.toString();
  }

  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

double? _parseWeight(String? text) {
  if (text == null || text.isEmpty) {
    return null;
  }
  return double.tryParse(text.replaceAll(',', ''));
}
