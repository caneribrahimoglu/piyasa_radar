class SellerAlertEvent {
  const SellerAlertEvent({
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
  });

  final String title;
  final String message;
  final DateTime createdAt;
  final String type;

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'createdAt': createdAt.toIso8601String(),
    'type': type,
  };

  factory SellerAlertEvent.fromJson(Map<String, dynamic> json) {
    return SellerAlertEvent(
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: json['type'] as String? ?? '',
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
