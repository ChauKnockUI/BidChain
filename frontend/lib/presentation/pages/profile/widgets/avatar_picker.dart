import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../config/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../widgets/common/custom_toast.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_state.dart';
import '../../../bloc/auth/auth_event.dart';

class AvatarPicker extends StatefulWidget {
  const AvatarPicker({super.key});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  bool _isUploading = false;
  final DioClient _dioClient = DioClient();

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _isUploading = true);
        await _uploadAvatar(image);
      }
    } catch (e) {
      Toast.show(context, message: 'Error: $e', type: ToastType.error);
    }
  }

  void _showAvatarOptions(String? avatarUrl) {
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Upload/Change Avatar Option
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.accent),
              title: Text(hasAvatar ? 'Change Avatar' : 'Upload Avatar'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            // Delete Avatar Option (only show if avatar exists)
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Avatar',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirm();
                },
              ),
            // Cancel Option
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Avatar'),
        content: const Text('Are you sure you want to delete your avatar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAvatar();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAvatar() async {
    try {
      setState(() => _isUploading = true);

      final response = await _dioClient.put(
        ApiConstants.updateUserProfile,
        data: {'avatar': null},
      );

      if (mounted) {
        if (response.statusCode == 200) {
          setState(() => _isUploading = false);
          Toast.show(
            context,
            message: 'Avatar deleted!',
            type: ToastType.success,
          );
          // Refresh user profile
          context.read<AuthBloc>().add(const AuthCheckStatusEvent());
        } else {
          setState(() => _isUploading = false);
          Toast.show(context, message: 'Delete failed', type: ToastType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        Toast.show(
          context,
          message: 'Error: ${e.toString()}',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _uploadAvatar(XFile image) async {
    try {
      // Read image bytes - works on both web and mobile
      final bytes = await image.readAsBytes();
      final filename = image.name;

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _dioClient.postMultipart(
        ApiConstants.uploadAvatar,
        data: formData,
      );

      if (mounted) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          setState(() => _isUploading = false);
          Toast.show(
            context,
            message: 'Avatar updated!',
            type: ToastType.success,
          );

          // Backend returns user data with new avatar URL
          // Force rebuild to fetch latest user data
          if (response.data != null && response.data['user'] != null) {
            // Trigger a refresh by requesting latest user profile
            context.read<AuthBloc>().add(const AuthCheckStatusEvent());
          }
        } else {
          setState(() => _isUploading = false);
          Toast.show(context, message: 'Upload failed', type: ToastType.error);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        Toast.show(
          context,
          message: 'Error: ${e.toString()}',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive size: Web (160) vs Mobile (120)
    final isWeb = MediaQuery.of(context).size.width > 600;
    final avatarSize = isWeb ? 160.0 : 120.0;
    const editIconSize = 32.0;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String? avatarUrl;
        if (state is AuthSuccessState) {
          avatarUrl = state.user.avatar;
        }

        return GestureDetector(
          onTap: _isUploading ? null : () => _showAvatarOptions(avatarUrl),
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.greyLight,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: _isUploading
                ? Center(child: CircularProgressIndicator(strokeWidth: 3))
                : (avatarUrl != null && avatarUrl.isNotEmpty)
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      // Avatar image with BoxFit.cover for quality
                      ClipOval(
                        child: Image.network(
                          avatarUrl,
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: avatarSize * 0.5,
                              color: AppColors.accent,
                            );
                          },
                        ),
                      ),
                      // Camera icon overlay at bottom right
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: editIconSize,
                          height: editIconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: editIconSize * 0.6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    Icons.add_a_photo,
                    size: avatarSize * 0.4,
                    color: AppColors.accent,
                  ),
          ),
        );
      },
    );
  }
}
