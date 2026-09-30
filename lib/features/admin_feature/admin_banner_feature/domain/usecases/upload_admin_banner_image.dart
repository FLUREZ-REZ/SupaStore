import 'package:image_picker/image_picker.dart';

import '../repositories/admin_banner_repository.dart';

class UploadAdminBannerImage {
  UploadAdminBannerImage({
    required AdminBannerRepository repository,
  }) : _repository = repository;

  final AdminBannerRepository _repository;

  Future<String> call({
    required XFile file,
  }) {
    return _repository.uploadBannerImage(
      file: file,
    );
  }
}