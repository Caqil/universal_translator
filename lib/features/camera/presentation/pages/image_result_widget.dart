// lib/features/camera/presentation/widgets/image_result_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';

class ImageResultWidget extends StatefulWidget {
  final String imagePath;
  final List<String> recognizedTexts;
  final List<String> translatedTexts;
  final bool isProcessing;
  final VoidCallback onRetakePressed;
  final Function(String sourceLanguage, String targetLanguage)
      onTranslatePressed;

  const ImageResultWidget({
    Key? key,
    required this.imagePath,
    required this.recognizedTexts,
    required this.translatedTexts,
    required this.isProcessing,
    required this.onRetakePressed,
    required this.onTranslatePressed,
  }) : super(key: key);

  @override
  State<ImageResultWidget> createState() => _ImageResultWidgetState();
}

class _ImageResultWidgetState extends State<ImageResultWidget> {
  String _sourceLanguage = 'auto';
  String _targetLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image preview
        Expanded(
          flex: 2,
          child: _buildImagePreview(),
        ),

        // Controls and results
        Expanded(
          flex: 3,
          child: _buildResultsSection(),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(widget.imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Language selection and translate button
          _buildLanguageControls(),

          const Gap(16),

          // Results
          Expanded(
            child: widget.isProcessing
                ? _buildProcessingIndicator()
                : _buildTranslationResults(),
          ),

          // Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildLanguageControls() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _sourceLanguage,
            decoration: InputDecoration(
              labelText: 'translation.source_language'.tr(),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: [
              DropdownMenuItem(
                value: 'auto',
                child: Text('languages.auto_detect'.tr()),
              ),
              const DropdownMenuItem(value: 'en', child: Text('English')),
              const DropdownMenuItem(value: 'es', child: Text('Spanish')),
              const DropdownMenuItem(value: 'fr', child: Text('French')),
              const DropdownMenuItem(value: 'de', child: Text('German')),
              const DropdownMenuItem(value: 'zh', child: Text('Chinese')),
              const DropdownMenuItem(value: 'ja', child: Text('Japanese')),
              const DropdownMenuItem(value: 'ko', child: Text('Korean')),
            ],
            onChanged: (value) {
              setState(() {
                _sourceLanguage = value!;
              });
            },
          ),
        ),
        const Gap(8),
        IconButton(
          onPressed: () {
            setState(() {
              final temp = _sourceLanguage;
              _sourceLanguage = _targetLanguage;
              _targetLanguage = temp;
            });
          },
          icon: const Icon(Iconsax.arrow_swap_horizontal),
        ),
        const Gap(8),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _targetLanguage,
            decoration: InputDecoration(
              labelText: 'translation.target_language'.tr(),
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'es', child: Text('Spanish')),
              DropdownMenuItem(value: 'fr', child: Text('French')),
              DropdownMenuItem(value: 'de', child: Text('German')),
              DropdownMenuItem(value: 'zh', child: Text('Chinese')),
              DropdownMenuItem(value: 'ja', child: Text('Japanese')),
              DropdownMenuItem(value: 'ko', child: Text('Korean')),
            ],
            onChanged: (value) {
              setState(() {
                _targetLanguage = value!;
              });
            },
          ),
        ),
        const Gap(8),
        ElevatedButton.icon(
          onPressed: widget.recognizedTexts.isNotEmpty && !widget.isProcessing
              ? () =>
                  widget.onTranslatePressed(_sourceLanguage, _targetLanguage)
              : null,
          icon: const Icon(Iconsax.language_square),
          label: Text('translation.translate'.tr()),
        ),
      ],
    );
  }

  Widget _buildProcessingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const Gap(16),
          Text('camera.processing_image'.tr()),
        ],
      ),
    );
  }

  Widget _buildTranslationResults() {
    if (widget.recognizedTexts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_text,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const Gap(16),
            Text(
              'camera.no_text_found'.tr(),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: widget.recognizedTexts.length,
      itemBuilder: (context, index) {
        final recognizedText = widget.recognizedTexts[index];
        final translatedText = index < widget.translatedTexts.length
            ? widget.translatedTexts[index]
            : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Original text
                Row(
                  children: [
                    Icon(
                      Iconsax.document_text,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const Gap(8),
                    Text(
                      'Original',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => _copyToClipboard(recognizedText),
                      icon: const Icon(Iconsax.copy, size: 16),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  ],
                ),
                const Gap(4),
                Text(
                  recognizedText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                if (translatedText != null) ...[
                  const Gap(12),
                  const Divider(height: 1),
                  const Gap(12),

                  // Translated text
                  Row(
                    children: [
                      Icon(
                        Iconsax.language_square,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const Gap(8),
                      Text(
                        'translation.translation'.tr(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _copyToClipboard(translatedText),
                        icon: const Icon(Iconsax.copy, size: 16),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ),
                  const Gap(4),
                  Text(
                    translatedText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onRetakePressed,
            icon: const Icon(Iconsax.camera),
            label: Text('camera.retake_photo'.tr()),
          ),
        ),
        const Gap(12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.recognizedTexts.isNotEmpty
                ? () => _shareResults()
                : null,
            icon: const Icon(Iconsax.share),
            label: Text('app.share'.tr()),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('translation.translation_copied'.tr()),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareResults() {
    // Implement sharing functionality
    final results = widget.recognizedTexts.asMap().entries.map((entry) {
      final index = entry.key;
      final original = entry.value;
      final translated = index < widget.translatedTexts.length
          ? widget.translatedTexts[index]
          : 'Not translated';
      return 'Original: $original\nTranslation: $translated\n';
    }).join('\n');

    // Use share_plus package to share
    // Share.share(results);
  }
}
