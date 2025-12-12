import 'package:get_it/get_it.dart';
import 'package:gonogo/layers/data/datasources/cloudinary_datasource.dart';
import 'package:gonogo/layers/data/datasources/remote/cloudinary_datasource_impl.dart';
import 'package:gonogo/layers/data/repositories/cloudinary_repository_impl.dart';
import 'package:gonogo/layers/domain/repositories/cloudinary_repository.dart';

final getIt = GetIt.instance;

void initInject() {
  getIt.registerLazySingleton<CloudinaryDataSource>(
    () => CloudinaryDataSourceImpl(),
  );
  getIt.registerLazySingleton<CloudinaryRepository>(
    () => CloudinaryRepositoryImpl(getIt()),
  );
}
