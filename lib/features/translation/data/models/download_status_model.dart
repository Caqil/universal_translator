// lib/features/translation/data/models/download_status_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/download_status.dart';

part 'download_status_model.g.dart';

@JsonSerializable()
class DownloadStatusModel {
  final String languageCode;
  final bool isDownloaded;
  final bool isDownloading;
  final double progress;
  final int sizeInBytes;
  final DateTime? downloadedAt;

  const DownloadStatusModel({
    required this.languageCode,
    required this.isDownloaded,
    required this.isDownloading,
    required this.progress,
    required this.sizeInBytes,
    this.downloadedAt,
  });

  factory DownloadStatusModel.fromJson(Map<String, dynamic> json) =>
      _$DownloadStatusModelFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadStatusModelToJson(this);

  DownloadStatus toEntity() => DownloadStatus(
        languageCode: languageCode,
        isDownloaded: isDownloaded,
        isDownloading: isDownloading,
        progress: progress,
        sizeInBytes: sizeInBytes,
        downloadedAt: downloadedAt,
      );
}
