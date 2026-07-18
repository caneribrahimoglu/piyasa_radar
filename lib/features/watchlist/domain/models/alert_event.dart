class AlertEvent {
  const AlertEvent({
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
  });

  final String title;
  final String message;
  final DateTime createdAt;
  final String type;

  String get formattedCreatedAt {
    final day = _twoDigits(createdAt.day);
    final month = _twoDigits(createdAt.month);
    final year = createdAt.year;
    final hour = _twoDigits(createdAt.hour);
    final minute = _twoDigits(createdAt.minute);

    return '$day.$month.$year $hour:$minute';
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
