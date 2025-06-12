// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadStatusModel _$DownloadStatusModelFromJson(Map<String, dynamic> json) =>
    DownloadStatusModel(
      languageCode: json['languageCode'] as String,
      isDownloaded: json['isDownloaded'] as bool,
      isDownloading: json['isDownloading'] as bool,
      progress: (json['progress'] as num).toDouble(),
      sizeInBytes: (json['sizeInBytes'] as num).toInt(),
      downloadedAt: json['downloadedAt'] == null
          ? null
          : DateTime.parse(json['downloadedAt'] as String),
    );

Map<String, dynamic> _$DownloadStatusModelToJson(
        DownloadStatusModel instance) =>
    <String, dynamic>{
      'languageCode': instance.languageCode,
      'isDownloaded': instance.isDownloaded,
      'isDownloading': instance.isDownloading,
      'progress': instance.progress,
      'sizeInBytes': instance.sizeInBytes,
      'downloadedAt': instance.downloadedAt?.toIso8601String(),
    };
