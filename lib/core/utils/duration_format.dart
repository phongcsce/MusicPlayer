import 'package:intl/intl.dart';

String formatPlayerDuration(Duration d) {
  final fmt = DateFormat('m:ss');
  return fmt.format(DateTime(0, 1, 1, 0, 0, 0).add(d));
}
