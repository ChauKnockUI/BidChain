import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    String? fullName,
    String? username,
    String? email,
    String? phoneNumber,
    String? country,
    String? city,
    String? district,
    String? address,
    String? bio,
  }) async {
    return await repository.updateProfile(
      fullName: fullName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      country: country,
      city: city,
      district: district,
      address: address,
      bio: bio,
    );
  }
}
