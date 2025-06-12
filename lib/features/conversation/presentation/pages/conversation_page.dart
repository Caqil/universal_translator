// lib/features/conversation/presentation/pages/conversation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../translation/presentation/widgets/language_selector.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import '../widgets/smart_voice_button.dart';
import '../widgets/conversation_message_widget.dart';

class ConversationPage extends StatefulWidget {
  final String user1Language;
  final String user2Language;
  final String user1LanguageName;
  final String user2LanguageName;

  const ConversationPage({
    super.key,
    this.user1Language = 'en',
    this.user2Language = 'es',
    this.user1LanguageName = 'English',
    this.user2LanguageName = 'Spanish',
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeConversation();
    });
  }

  void _initializeConversation() {
    print('🎯 Initializing conversation page');
    context.read<ConversationBloc>().add(const InitializeConversationEvent());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context.brightness),
      body: BlocConsumer<ConversationBloc, ConversationState>(
        listener: (context, state) {
          final sonner = ShadSonner.of(context);

          if (state.hasError) {
            sonner.show(
              ShadToast.destructive(
                title: Text('Error'),
                description: Text(state.errorMessage!),
              ),
            );
          }

          if (state.messages.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(state),
                Expanded(child: _buildBody(state)),
                _buildVoiceControls(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ConversationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title
          Text(
            'conversation.conversation_mode'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),

          const SizedBox(height: 16),

          // Language Selection Row using LanguageSelector
          if (state.supportedLanguages.isNotEmpty) ...[
            Row(
              children: [
                // User 1 Language Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'conversation.speaker_1'.tr(),
                        style: TextStyle(
                          color: const Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LanguageSelector(
                        selectedLanguage: state.user1Language,
                        supportedLanguages: state.supportedLanguages,
                        isCompact: true,
                        onLanguageSelected: (language) {
                          print('🎯 User 1 language selected: $language');
                          context.read<ConversationBloc>().add(
                                UpdateLanguagesEvent(
                                  user1Language: language,
                                  user2Language: state.user2Language,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Swap Button
                GestureDetector(
                  onTap: () => _swapLanguages(state),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                      ),
                    ),
                    child: Icon(
                      Iconsax.arrow_swap_horizontal,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // User 2 Language Selector
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'conversation.speaker_2'.tr(),
                        style: TextStyle(
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LanguageSelector(
                        selectedLanguage: state.user2Language,
                        supportedLanguages: state.supportedLanguages,
                        isCompact: true,
                        onLanguageSelected: (language) {
                          print('🎯 User 2 language selected: $language');
                          context.read<ConversationBloc>().add(
                                UpdateLanguagesEvent(
                                  user1Language: state.user1Language,
                                  user2Language: language,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Auto-speak toggle
            if (state.session != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.volume_high,
                    size: 16,
                    color: state.autoSpeak
                        ? AppColors.primary(context.brightness)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Auto-speak',
                    style: TextStyle(
                      color: state.autoSpeak
                          ? AppColors.primary(context.brightness)
                          : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: state.autoSpeak,
                    onChanged: (value) => context.read<ConversationBloc>().add(
                          ToggleAutoSpeakEvent(value),
                        ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(ConversationState state) {
    if (state.status == ConversationStatus.settingUp) {
      return _buildLoadingState();
    }

    if (state.messages.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMessagesList(state);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary(context.brightness),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Setting up conversation...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary(context.brightness).withOpacity(0.1),
              ),
              child: Icon(
                Iconsax.messages_2,
                size: 50,
                color: AppColors.primary(context.brightness),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'conversation.start_talking'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'conversation.tap_to_speak'.tr(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList(ConversationState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final message = state.messages[index];
        return ConversationMessageWidget(
          message: message,
          isPlaying: state.currentlyPlayingMessageId == message.id,
          onPlayAudio: () => context.read<ConversationBloc>().add(
                PlayMessageAudioEvent(message.id),
              ),
          onRetryTranslation: () => context.read<ConversationBloc>().add(
                RetryTranslationEvent(message.id),
              ),
        );
      },
    );
  }

  Widget _buildVoiceControls(ConversationState state) {
    if (state.session == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // User 1 Button
          Expanded(
            child: SmartVoiceButton(
              language: state.session!.user1Language,
              languageName: state.session!.user1LanguageName,
              primaryColor: const Color(0xFF3B82F6),
              isListening: state.isListening && state.isUser1Active,
              isActive: state.isUser1Active,
              isProcessing: state.status == ConversationStatus.processing &&
                  state.isUser1Active,
              confidence: state.isUser1Active ? state.currentConfidence : null,
              onPressed: () => _handleVoiceButtonPressed(true, state),
              enabled: state.canStartListening,
            ),
          ),

          const SizedBox(width: 24),

          // Center status
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getStatusColor(state).withOpacity(0.1),
            ),
            child: Icon(
              _getStatusIcon(state),
              color: _getStatusColor(state),
              size: 20,
            ),
          ),

          const SizedBox(width: 24),

          // User 2 Button
          Expanded(
            child: SmartVoiceButton(
              language: state.session!.user2Language,
              languageName: state.session!.user2LanguageName,
              primaryColor: const Color(0xFF10B981),
              isListening: state.isListening && !state.isUser1Active,
              isActive: !state.isUser1Active,
              isProcessing: state.status == ConversationStatus.processing &&
                  !state.isUser1Active,
              confidence: !state.isUser1Active ? state.currentConfidence : null,
              onPressed: () => _handleVoiceButtonPressed(false, state),
              enabled: state.canStartListening,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ConversationState state) {
    switch (state.status) {
      case ConversationStatus.listening:
        return const Color(0xFFEF4444);
      case ConversationStatus.processing:
        return const Color(0xFFF59E0B);
      case ConversationStatus.speaking:
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ConversationState state) {
    switch (state.status) {
      case ConversationStatus.listening:
        return Iconsax.microphone;
      case ConversationStatus.processing:
        return Iconsax.translate;
      case ConversationStatus.speaking:
        return Iconsax.volume_high;
      default:
        return Iconsax.messages_2;
    }
  }

  void _handleVoiceButtonPressed(bool isUser1, ConversationState state) {
    print('🎯 Voice button pressed: User${isUser1 ? 1 : 2}');

    HapticFeedback.mediumImpact();

    if (state.isListening) {
      context.read<ConversationBloc>().add(const StopListeningEvent());
    } else {
      context
          .read<ConversationBloc>()
          .add(StartListeningEvent(isUser1: isUser1));
    }
  }

  void _swapLanguages(ConversationState state) {
    print('🎯 Swapping languages');
    context.read<ConversationBloc>().add(
          UpdateLanguagesEvent(
            user1Language: state.user2Language,
            user2Language: state.user1Language,
          ),
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
