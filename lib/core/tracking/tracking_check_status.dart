enum TrackingCheckStatus { neverChecked, checking, success, failed }

TrackingCheckStatus trackingCheckStatusFromJson(Object? value) {
  if (value is! String) return TrackingCheckStatus.neverChecked;

  for (final status in TrackingCheckStatus.values) {
    if (status.name == value) return status;
  }

  return TrackingCheckStatus.neverChecked;
}

String trackingCheckStatusToJson(TrackingCheckStatus status) => status.name;

extension TrackingCheckStatusLabel on TrackingCheckStatus {
  String get label {
    return switch (this) {
      TrackingCheckStatus.neverChecked => 'Henüz kontrol edilmedi',
      TrackingCheckStatus.checking => 'Kontrol ediliyor',
      TrackingCheckStatus.success => 'Kontrol başarılı',
      TrackingCheckStatus.failed => 'Kontrol başarısız',
    };
  }
}
