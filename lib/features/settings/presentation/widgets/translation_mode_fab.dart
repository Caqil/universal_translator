
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../../../translation/data/models/translation_mode_model.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class TranslationModeFAB extends StatelessWidget {
  const TranslationModeFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        if (state is! SettingsLoaded) {
          return const SizedBox.shrink();
        }

        return FloatingActionButton.extended(
          onPressed: () => _showModeSelector(context, state.translationMode),
          icon: _getModeIcon(state.translationMode),
          label: Text(state.translationMode.displayName),
          backgroundColor: _getModeColor(context, state.translationMode),
        );
      },
    );
  }

  Icon _getModeIcon(TranslationMode mode) {
    switch (mode) {
      case TranslationMode.online:
        return const Icon(Icons.cloud);
      case TranslationMode.offline:
        return const Icon(Icons.cloud_off);
      case TranslationMode.auto:
        return const Icon(Icons.auto_mode);
    }
  }

  Color _getModeColor(BuildContext context, TranslationMode mode) {
    switch (mode) {
      case TranslationMode.online:
        return Colors.blue;
      case TranslationMode.offline:
        return Colors.green;
      case TranslationMode.auto:
        return Theme.of(context).primaryColor;
    }
  }

  void _showModeSelector(BuildContext context, TranslationMode currentMode) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Translation Mode',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...TranslationMode.values.map((mode) {
                return ListTile(
                  leading: _getModeIcon(mode),
                  title: Text(mode.displayName),
                  subtitle: Text(_getModeDescription(mode)),
                  trailing: currentMode == mode
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    context
                        .read<SettingsBloc>()
                        .add(ToggleTranslationMode(mode));
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  String _getModeDescription(TranslationMode mode) {
    switch (mode) {
      case TranslationMode.online:
        return 'Use internet for translation';
      case TranslationMode.offline:
        return 'Use downloaded language models';
      case TranslationMode.auto:
        return 'Automatically choose best option';
    }
  }
}
