import '../../domain/entities/category_entity.dart';
import '../datasources/remote/category_remote_datasource.dart';

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      return categories.map((model) => CategoryEntity(
        id: model.id,
        name: model.name,
      )).toList();
    } catch (e) {
      rethrow;
    }
  }
}
