class ReportHistoryEntry {
  final String id;
  final String reportName;
  final String reportType;
  final String exportFormat;
  final String filePath;
  final int fileSize; // In bytes
  final int pageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status; // 'Available', 'Archived', 'Deleted', 'Corrupted', 'Missing File'
  final String template;
  final Map<String, dynamic> filtersApplied;
  final String ownerId;
  final String syncStatus;

  const ReportHistoryEntry({
    required this.id,
    required this.reportName,
    required this.reportType,
    required this.exportFormat,
    required this.filePath,
    required this.fileSize,
    required this.pageCount,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.template,
    required this.filtersApplied,
    required this.ownerId,
    required this.syncStatus,
  });

  ReportHistoryEntry copyWith({
    String? id,
    String? reportName,
    String? reportType,
    String? exportFormat,
    String? filePath,
    int? fileSize,
    int? pageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? template,
    Map<String, dynamic>? filtersApplied,
    String? ownerId,
    String? syncStatus,
  }) {
    return ReportHistoryEntry(
      id: id ?? this.id,
      reportName: reportName ?? this.reportName,
      reportType: reportType ?? this.reportType,
      exportFormat: exportFormat ?? this.exportFormat,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      pageCount: pageCount ?? this.pageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      template: template ?? this.template,
      filtersApplied: filtersApplied ?? this.filtersApplied,
      ownerId: ownerId ?? this.ownerId,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportHistoryEntry &&
        other.id == id &&
        other.reportName == reportName &&
        other.reportType == reportType &&
        other.exportFormat == exportFormat &&
        other.filePath == filePath &&
        other.fileSize == fileSize &&
        other.pageCount == pageCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.status == status &&
        other.template == template &&
        other.ownerId == ownerId &&
        other.syncStatus == syncStatus;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      reportName,
      reportType,
      exportFormat,
      filePath,
      fileSize,
      pageCount,
      createdAt,
      updatedAt,
      status,
      template,
      ownerId,
      syncStatus,
    );
  }
}
