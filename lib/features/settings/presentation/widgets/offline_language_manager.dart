// lib/features/settings/presentation/widgets/offline_language_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../bloc/settings_bloc.dart';
import '../../../translation/domain/entities/language.dart';
import '../../../translation/domain/entities/download_status.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class OfflineLanguageManager extends StatelessWidget {
  final List<Language> availableLanguages;

  const OfflineLanguageManager({
    super.key,
    required this.availableLanguages,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'manage_offline_languages'.tr(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'offline_languages_description'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...availableLanguages
                  .map((language) => _buildLanguageItem(
                      context, language, state.downloadedLanguages))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageItem(
    BuildContext context,
    Language language,
    List<DownloadStatus> downloadedLanguages,
  ) {
    final downloadStatus = downloadedLanguages.firstWhere(
      (status) => status.languageCode == language.code,
      orElse: () => DownloadStatus(
        languageCode: language.code,
        isDownloaded: false,
        isDownloading: false,
        progress: 0.0,
        sizeInBytes: 45 * 1024 * 1024, // 45MB default
      ),
    );

    return ListTile(
      leading: Text(
        language.flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(language.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(language.nativeName),
          if (downloadStatus.isDownloading)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: LinearProgressIndicator(
                value: downloadStatus.progress,
                backgroundColor: Colors.grey[300],
              ),
            ),
          if (downloadStatus.isDownloaded)
            Text(
              'downloaded'.tr(),
              style: TextStyle(
                color: Colors.green[600],
                fontSize: 12,
              ),
            ),
        ],
      ),
      trailing: _buildActionButton(context, downloadStatus),
    );
  }

  Widget _buildActionButton(BuildContext context, DownloadStatus status) {
    if (status.isDownloading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: status.progress,
        ),
      );
    }

    if (status.isDownloaded) {
      return IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          _showDeleteConfirmation(context, status.languageCode);
        },
      );
    }

    return IconButton(
      icon: const Icon(Icons.download),
      onPressed: () {
        context.read<SettingsBloc>().add(
              DownloadLanguageModel(status.languageCode),
            );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String languageCode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('delete_language'.tr()),
          content: Text('delete_language_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<SettingsBloc>().add(
                      DeleteLanguageModel(languageCode),
                    );
              },
              child: Text('delete'.tr()),
            ),
          ],
        );
      },
    );
  }
}
