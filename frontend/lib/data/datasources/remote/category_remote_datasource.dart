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

    final List<dynamic> jsonList = response.data;
    return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
  }
}
