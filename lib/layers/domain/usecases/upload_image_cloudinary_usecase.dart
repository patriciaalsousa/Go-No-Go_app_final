import 'package:image_picker/image_picker.dart';
import '../repositories/cloudinary_repository.dart';

abstract class UploadImageCloudinaryUseCase {
  Future<String?> call(XFile image);
}

class UploadImageCloudinaryUseCaseImpl implements UploadImageCloudinaryUseCase {
  final CloudinaryRepository _repository;

  UploadImageCloudinaryUseCaseImpl(this._repository);

  @override
  Future<String?> call(XFile image) async {
    return await _repository.uploadImage(image);
  }
}
