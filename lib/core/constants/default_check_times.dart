const defaultCheckTimes = ['09:00', '14:00', '20:00'];

String formatCheckTime(int hour, int minute) {
  final formattedHour = hour.toString().padLeft(2, '0');
  final formattedMinute = minute.toString().padLeft(2, '0');
  return '$formattedHour:$formattedMinute';
}

List<String> normalizeCheckTimes(
  Iterable<String> times, {
  List<String> fallback = const [],
}) {
  final normalized = <String>{};
  for (final time in times) {
    final normalizedTime = _normalizeCheckTime(time);
    if (normalizedTime != null) normalized.add(normalizedTime);
  }

  if (normalized.isEmpty) return List.unmodifiable(fallback);
  final sorted = normalized.toList()..sort();
  return List.unmodifiable(sorted);
}

String? _normalizeCheckTime(String value) {
  final parts = value.trim().split(':');
  if (parts.length != 2) return null;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

  return formatCheckTime(hour, minute);
}
