class AlertSummaryItem {
  const AlertSummaryItem({
    required this.id,
    required this.sourceType,
    required this.sourceName,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final String sourceType;
  final String sourceName;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  AlertSummaryItem copyWith({
    String? id,
    String? sourceType,
    String? sourceName,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AlertSummaryItem(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceName: sourceName ?? this.sourceName,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

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
