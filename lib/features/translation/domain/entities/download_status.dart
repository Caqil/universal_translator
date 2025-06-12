// lib/features/translation/domain/entities/download_status.dart
import 'package:equatable/equatable.dart';

class DownloadStatus extends Equatable {
  final String languageCode;
  final bool isDownloaded;
  final bool isDownloading;
  final double progress;
  final int sizeInBytes;
  final DateTime? downloadedAt;

  const DownloadStatus({
    required this.languageCode,
    required this.isDownloaded,
    required this.isDownloading,
    required this.progress,
    required this.sizeInBytes,
    this.downloadedAt,
  });

  @override
  List<Object?> get props => [
        languageCode,
        isDownloaded,
        isDownloading,
        progress,
        sizeInBytes,
        downloadedAt,
      ];

  DownloadStatus copyWith({
    String? languageCode,
    bool? isDownloaded,
    bool? isDownloading,
    double? progress,
    int? sizeInBytes,
    DateTime? downloadedAt,
  }) {
    return DownloadStatus(
      languageCode: languageCode ?? this.languageCode,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isDownloading: isDownloading ?? this.isDownloading,
      progress: progress ?? this.progress,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }
}
