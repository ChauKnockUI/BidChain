import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../config/theme/app_colors.dart';
import '../../../core/di/injection_container.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/create_auction_request.dart';
import '../../bloc/create_auction/create_auction_bloc.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class CreateAuctionScreen extends StatelessWidget {
  const CreateAuctionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectionContainer.getCreateAuctionBloc()..add(LoadCategoriesEvent()),
      child: const _CreateAuctionView(),
    );
  }
}

class _CreateAuctionView extends StatefulWidget {
  const _CreateAuctionView();

  @override
  State<_CreateAuctionView> createState() => _CreateAuctionViewState();
}

class _CreateAuctionViewState extends State<_CreateAuctionView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _stepPriceController = TextEditingController();
  DateTime? _endTime;
  String? _selectedCategoryId;
  final List<File> _selectedImages = [];
  final List<String> _imageUrls = [];
  List<CategoryModel> _categories = [];
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startPriceController.dispose();
    _stepPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      final newImages = images.map((e) => File(e.path)).toList();
      setState(() {
        _selectedImages.addAll(newImages);
        _isUploading = true;
      });
      context.read<CreateAuctionBloc>().add(UploadImagesEvent(newImages));
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      if (index < _imageUrls.length) {
        _imageUrls.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateAuctionBloc, CreateAuctionState>(
      listener: _handleStateChange,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppBar(context),
        body: BlocBuilder<CreateAuctionBloc, CreateAuctionState>(
          builder: (context, state) {
            final isLoading = state is CreateAuctionLoading && !_isUploading;
            return _buildBody(isLoading);
          },
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: CustomButton(
            color: AppColors.accent,
            text: 'Submit Art Auction',
            onPressed: _submitAuction,
          ),
        ),
      ),
    );
  }

  void _handleStateChange(BuildContext context, CreateAuctionState state) {
    print('🔔 State changed: ${state.runtimeType}');

    if (state is CategoriesLoaded) {
      print('✅ Categories loaded: ${state.categories.length} categories');
      for (var cat in state.categories) {
        print('   - Category: id=${cat.id}, name=${cat.name}');
      }
      setState(() {
        _categories = state.categories;
        print(
          '✅ _categories updated in widget state: ${_categories.length} items',
        );
      });
    } else if (state is ImagesUploaded) {
      setState(() {
        _imageUrls.addAll(state.imageUrls);
        _isUploading = false;
      });
      _showSnackBar(context, 'Images uploaded successfully!');
    } else if (state is CreateAuctionSuccess) {
      _showSnackBar(context, 'Auction created successfully!');
      context.pop();
    } else if (state is CreateAuctionFailure) {
      setState(() {
        _isUploading = false;
      });
      _showSnackBar(context, state.message);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Create Auction',
        style: TextStyle(
          color: AppColors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: AppColors.accent,
        onPressed: () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Product Name',
              controller: _titleController,
              hint: 'Name of the product.',
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Product Description',
              controller: _descriptionController,
              hint: 'Detail infomation of product.',
            ),
            const SizedBox(height: 20),
            _buildLabel('Category'),
            _buildCategoryDropdown(),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Minimum Bid',
              controller: _startPriceController,
              hint: '100.000 VND',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Step Bid',
              controller: _stepPriceController,
              hint: '500.000 VND',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            _buildLabel('End Time'),
            _buildDatePicker(context),
            const SizedBox(height: 20),
            if (_selectedImages.isEmpty) _buildImageUploadPlaceholder(),
            if (_selectedImages.isNotEmpty) _buildImagePreview(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        CustomTextField(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType ?? TextInputType.text,
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownMenuTheme(
      data: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          // ignore: deprecated_member_use
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.greyLight),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCategoryId,
            isExpanded: true,
            hint: Text(
              'Select Category',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            items: _categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCategoryId = value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: _selectDateTime,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.greyLight),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _endTime != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(_endTime!)
                  : 'Select Date & Time',
              style: TextStyle(
                fontSize: 14,
                color: _endTime != null ? AppColors.black : AppColors.grey,
              ),
            ),
            Icon(Icons.calendar_today, color: AppColors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null && mounted) {
        setState(() {
          _endTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Widget _buildImageUploadPlaceholder() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_upward,
                color: AppColors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Upload an image',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImagePreviewHeader(),
        const SizedBox(height: 12),
        _buildImageGrid(),
      ],
    );
  }

  Widget _buildImagePreviewHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_selectedImages.length} image(s) selected',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
        TextButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add More'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.info,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImages.length,
      itemBuilder: (context, index) => _buildImageGridItem(index),
    );
  }

  Widget _buildImageGridItem(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.greyLight),
            image: DecorationImage(
              image: FileImage(_selectedImages[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (_isUploading && index >= _imageUrls.length)
          _buildUploadingOverlay(),
        Positioned(top: 4, right: 4, child: _buildRemoveButton(index)),
      ],
    );
  }

  Widget _buildUploadingOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.black.withOpacity(0.5),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
        ),
      ),
    );
  }

  Widget _buildRemoveButton(int index) {
    return GestureDetector(
      onTap: () => _removeImage(index),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: AppColors.white, size: 16),
      ),
    );
  }

  void _submitAuction() {
    if (!_validateForm()) return;

    final request = CreateAuctionRequest(
      title: _titleController.text,
      description: _descriptionController.text,
      startPrice: double.tryParse(_startPriceController.text) ?? 0,
      stepPrice: double.tryParse(_stepPriceController.text) ?? 0,
      endTime: _endTime!,
      images: _imageUrls,
      categoryId: _selectedCategoryId!,
    );

    context.read<CreateAuctionBloc>().add(SubmitAuctionEvent(request));
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(context, 'Please fill all required fields');
      return false;
    }

    if (_selectedCategoryId == null) {
      _showSnackBar(context, 'Please select a category');
      return false;
    }

    if (_endTime == null) {
      _showSnackBar(context, 'Please select end time');
      return false;
    }

    if (_imageUrls.isEmpty) {
      if (_selectedImages.isNotEmpty && _isUploading) {
        _showSnackBar(context, 'Please wait for images to upload');
      } else {
        _showSnackBar(context, 'Please upload at least one image');
      }
      return false;
    }

    return true;
  }
}
