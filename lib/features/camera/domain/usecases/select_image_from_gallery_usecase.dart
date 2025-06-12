import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/camera_repository.dart';

@injectable
class SelectImageFromGalleryUseCase implements UseCase<String?, NoParams> {
  final CameraRepository _repository;

  SelectImageFromGalleryUseCase(this._repository);

  @override
  Future<Either<Failure, String?>> call(NoParams params) async {
    return await _repository.selectImageFromGallery();
  }
}
