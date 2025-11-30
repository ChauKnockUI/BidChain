import 'package:frontend/config/constants/api_constants.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/data/models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final DioClient dioClient;

  CategoryRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await dioClient.get(ApiConstants.getCategories);

    // API returns {success: true, data: [...]}
    if (response.data is Map && response.data['success'] == true) {
      final List<dynamic> jsonList = response.data['data'];
      final reversedList = jsonList.reversed.toList();

      return reversedList.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
