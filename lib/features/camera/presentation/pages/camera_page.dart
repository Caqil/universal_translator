
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/services/injection_container.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../translation/presentation/bloc/translation_bloc.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';
import 'camera_controls.dart';
import 'camera_preview_widget.dart';
import 'image_result_widget.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  late CameraBloc _cameraBloc;
  late TranslationBloc _translationBloc;

  @override
  void initState() {
    super.initState();
    _cameraBloc = sl<CameraBloc>();
    _translationBloc = sl<TranslationBloc>();
    WidgetsBinding.instance.addObserver(this);
    _cameraBloc.add(InitializeCamera());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraBloc.add(DisposeCamera());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      _cameraBloc.add(DisposeCamera());
    } else if (state == AppLifecycleState.resumed) {
      _cameraBloc.add(InitializeCamera());
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = context.brightness;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cameraBloc),
        BlocProvider.value(value: _translationBloc),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background(brightness),
        appBar: AppBar(
          title: Text(
            'camera.camera_translation'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.foreground(brightness),
                ),
          ),
          backgroundColor: AppColors.surface(brightness),
          elevation: 0,
          actions: [
            BlocBuilder<CameraBloc, CameraState>(
              builder: (context, state) {
                if (state is CameraReady) {
                  return IconButton(
                    onPressed: () => _cameraBloc.add(ToggleFlash()),
                    icon: Icon(
                      state.isFlashOn ? Iconsax.flash : Iconsax.flash_slash,
                      color: state.isFlashOn
                          ? AppColors.warning(brightness)
                          : AppColors.mutedForeground(brightness),
                    ),
                    tooltip: state.isFlashOn
                        ? 'camera.flash_off'.tr()
                        : 'camera.flash_on'.tr(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<CameraBloc, CameraState>(
          listener: (context, state) {
            if (state is CameraError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.destructive(brightness),
                ),
              );
            }
          },
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStateWidget(context, state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStateWidget(BuildContext context, CameraState state) {
    switch (state.runtimeType) {
      case CameraInitial:
      case CameraLoading:
        return _buildLoadingWidget();

      case CameraReady:
        return _buildCameraPreview(state as CameraReady);

      case ImageCaptured:
        return _buildImageResult(state as ImageCaptured);

      case CameraError:
        return _buildErrorWidget(state as CameraError);

      default:
        return _buildLoadingWidget();
    }
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Gap(16),
          Text('Loading camera...'),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(CameraReady state) {
    return Column(
      children: [
        Expanded(
          child: CameraPreviewWidget(
            controller: state.controller,
            isProcessing: state.isProcessing,
          ),
        ),
        CameraControls(
          onCapturePressed: () => _cameraBloc.add(CaptureImage()),
          onGalleryPressed: () => _cameraBloc.add(SelectImageFromGallery()),
          isProcessing: state.isProcessing,
        ),
      ],
    );
  }

  Widget _buildImageResult(ImageCaptured state) {
    return ImageResultWidget(
      imagePath: state.imagePath,
      recognizedTexts: state.recognizedTexts,
      translatedTexts: state.translatedTexts,
      isProcessing: state.isProcessing,
      onRetakePressed: () => _cameraBloc.add(RetakePhoto()),
      onTranslatePressed: (sourceLanguage, targetLanguage) {
        _cameraBloc.add(ProcessImageForTranslation(
          imagePath: state.imagePath,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
        ));
      },
    );
  }

  Widget _buildErrorWidget(CameraError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.camera_slash,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const Gap(16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: () => _cameraBloc.add(InitializeCamera()),
              child: Text('app.retry'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
