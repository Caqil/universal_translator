import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/history_item.dart';

class HistoryItemWidget extends StatelessWidget {
  final HistoryItem item;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  const HistoryItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.onFavoriteToggle,
    this.onDelete,
    this.onCopy,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return ShadCard(
      // onTap: onTap,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, brightness),
          const SizedBox(height: AppConstants.smallPadding),
          _buildContent(context, brightness),
          const SizedBox(height: AppConstants.smallPadding),
          _buildFooter(context, brightness),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Brightness brightness) {
    return Row(
      children: [
        // Language indicators
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.smallPadding,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: Text(
            '${item.sourceLanguage.toUpperCase()} → ${item.targetLanguage.toUpperCase()}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const Spacer(),
        // Favorite button
        IconButton(
          onPressed: onFavoriteToggle,
          icon: Icon(
            item.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: item.isFavorite
                ? Colors.red
                : Theme.of(context).iconTheme.color,
            size: 20,
          ),
          constraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 32,
          ),
          padding: EdgeInsets.zero,
        ),
        // More options
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          constraints: const BoxConstraints(
            minWidth: 150,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'copy',
              child: Row(
                children: [
                  const Icon(Icons.copy, size: 18),
                  const SizedBox(width: 8),
                  Text('app.copy'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  const Icon(Icons.share, size: 18),
                  const SizedBox(width: 8),
                  Text('app.share'.tr()),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 18, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'app.delete'.tr(),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert, size: 20),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: Text(
            item.sourceText,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        // Translated text
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.smallPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
          child: Text(
            item.translatedText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, Brightness brightness) {
    return Row(
      children: [
        // Timestamp
        Text(
          AppUtils.formatTime(item.timestamp),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
        ),
        if (item.confidence != null) ...[
          const SizedBox(width: AppConstants.smallPadding),
          // Confidence indicator
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _getConfidenceColor(item.confidence!).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${(item.confidence! * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getConfidenceColor(item.confidence!),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
        const Spacer(),
        // Action buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onCopy,
              icon: const Icon(Icons.copy, size: 18),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              onPressed: onShare,
              icon: const Icon(Icons.share, size: 18),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'copy':
        onCopy?.call();
        break;
      case 'share':
        onShare?.call();
        break;
      case 'delete':
        onDelete?.call();
        break;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
