import 'package:intl/intl.dart';

class GroupNameGenerator {
  GroupNameGenerator._();

  static final _format = DateFormat('d MMM yyyy, h:mm a');

  static String fromDateTime(DateTime dateTime) {
    return _format.format(dateTime);
  }

  static String uniqueName(DateTime dateTime, Iterable<String> existingNames) {
    final base = fromDateTime(dateTime);
    if (!existingNames.contains(base)) {
      return base;
    }

    var suffix = 2;
    while (existingNames.contains('$base ($suffix)')) {
      suffix++;
    }
    return '$base ($suffix)';
  }
}
