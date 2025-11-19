import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/services/localization_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/hotel_api_service.dart';

class DetailHotelReviewUserScreen extends StatefulWidget {
  final int hotelId;
  final String hotelName;
  final String hotelLocation;
  final String hotelImage;

  const DetailHotelReviewUserScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
    required this.hotelLocation,
    required this.hotelImage,
  });

  @override
  State<DetailHotelReviewUserScreen> createState() =>
      _DetailHotelReviewUserScreenState();
}

class _DetailHotelReviewUserScreenState
    extends State<DetailHotelReviewUserScreen> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final List<String> _selectedImages = []; // Local file paths
  final ImagePicker _picker = ImagePicker();

  // Hotel-specific aspects (1-5 stars)
  int _cleanlinessRating = 0;
  int _serviceRating = 0;
  int _valueForMoneyRating = 0;
  int _locationRating = 0;
  int _facilitiesRating = 0;

  @override
  void dispose() {
    _reviewController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _selectRating(int rating) {
    setState(() {
      _selectedRating = rating;
    });
  }

  Future<void> _addImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Chọn hình ảnh',
            style: context.h5Style.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(LucideIcons.camera, color: context.primaryColor),
                title: Text(
                  'Chụp ảnh',
                  style: context.bodyOneStyle.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(LucideIcons.image, color: context.primaryColor),
                title: Text(
                  'Chọn từ thư viện',
                  style: context.bodyOneStyle.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image.path);
        });
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Không thể chụp ảnh';
      if (e.code == 'camera_access_denied') {
        errorMessage = 'Quyền truy cập camera bị từ chối.';
      } else if (e.code == 'permission_denied') {
        errorMessage = 'Cần cấp quyền truy cập camera.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image.path);
        });
      }
    } on PlatformException catch (e) {
      String errorMessage = 'Không thể chọn ảnh';
      if (e.code == 'photo_access_denied') {
        errorMessage = 'Quyền truy cập thư viện ảnh bị từ chối.';
      } else if (e.code == 'permission_denied') {
        errorMessage = 'Cần cấp quyền truy cập thư viện ảnh.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    // Validate overall rating
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_select_rating'.tr),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate review content
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung đánh giá'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate all aspect ratings
    if (_cleanlinessRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đánh giá độ sạch sẽ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_serviceRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đánh giá dịch vụ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_valueForMoneyRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đánh giá giá trị'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_locationRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đánh giá vị trí'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_facilitiesRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đánh giá tiện nghi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const CircularProgressIndicator(),
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để đánh giá'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final api = HotelApiService(dio: Dio(), prefs: prefs);

      // Upload images to Cloudinary first
      final List<String> uploadedUrls = [];
      if (_selectedImages.isNotEmpty) {
        for (String imagePath in _selectedImages) {
          try {
            final url = await api.uploadReviewImage(imagePath);
            uploadedUrls.add(url);
          } catch (e) {
            // Log error but continue with other images
            debugPrint('Failed to upload image: $e');
          }
        }
      }

      // Create review with uploaded image URLs
      await api.createHotelReview(
        hotelId: widget.hotelId,
        userId: userId,
        rating: _selectedRating,
        title: _titleController.text.trim(),
        content: _reviewController.text.trim(),
        imageUrls: uploadedUrls.isNotEmpty ? uploadedUrls : null,
        aspects: {
          'cleanliness': _cleanlinessRating,
          'service': _serviceRating,
          'valueForMoney': _valueForMoneyRating,
          'location': _locationRating,
          'facilities': _facilitiesRating,
        },
      );

      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('review_submitted_success'.tr),
          backgroundColor: Colors.green,
        ),
      );

      // Go back to hotel detail and refresh
      Navigator.of(context).pop(true);
    } catch (e) {
      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đánh giá thất bại: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 5:
        return 'Xuất sắc';
      case 4:
        return 'Tốt';
      case 3:
        return 'Trung bình';
      case 2:
        return 'Kém';
      case 1:
        return 'Rất tệ';
      default:
        return 'Chọn đánh giá';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: context.textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hotel header
                    _HotelHeader(
                      name: widget.hotelName,
                      location: widget.hotelLocation,
                      image: widget.hotelImage,
                    ),

                    const SizedBox(height: 32),

                    // Overall rating question
                    Text(
                      'rate_experience_question'.tr,
                      style: context.h5Style.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Star rating
                    _StarRating(
                      selectedRating: _selectedRating,
                      onRatingSelected: _selectRating,
                    ),

                    const SizedBox(height: 12),

                    // Rating label
                    Center(
                      child: Text(
                        _getRatingLabel(_selectedRating),
                        style: context.subTitleTwoStyle.copyWith(
                          color: context.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Hotel aspects section
                    Text(
                      'Đánh giá chi tiết',
                      style: context.h5Style.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 16),

                    _AspectRating(
                      label: 'Độ sạch sẽ',
                      icon: LucideIcons.sparkles,
                      rating: _cleanlinessRating,
                      onChanged: (val) =>
                          setState(() => _cleanlinessRating = val),
                    ),
                    const SizedBox(height: 12),
                    _AspectRating(
                      label: 'Dịch vụ',
                      icon: LucideIcons.userCheck,
                      rating: _serviceRating,
                      onChanged: (val) => setState(() => _serviceRating = val),
                    ),
                    const SizedBox(height: 12),
                    _AspectRating(
                      label: 'Giá trị',
                      icon: LucideIcons.dollarSign,
                      rating: _valueForMoneyRating,
                      onChanged: (val) =>
                          setState(() => _valueForMoneyRating = val),
                    ),
                    const SizedBox(height: 12),
                    _AspectRating(
                      label: 'Vị trí',
                      icon: LucideIcons.mapPin,
                      rating: _locationRating,
                      onChanged: (val) => setState(() => _locationRating = val),
                    ),
                    const SizedBox(height: 12),
                    _AspectRating(
                      label: 'Tiện nghi',
                      icon: LucideIcons.wifi,
                      rating: _facilitiesRating,
                      onChanged: (val) =>
                          setState(() => _facilitiesRating = val),
                    ),

                    const SizedBox(height: 32),

                    // Review title
                    Text(
                      'review_title_label'.tr,
                      style: context.bodyOneStyle.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'review_title_hint'.tr,
                        hintStyle: context.bodyTwoStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
                        filled: true,
                        fillColor: context.dividerColor.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: context.bodyOneStyle.copyWith(
                        color: context.textPrimaryColor,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Review content
                    Text(
                      'review_content_label'.tr,
                      style: context.bodyOneStyle.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _reviewController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'review_content_hint'.tr,
                        hintStyle: context.bodyTwoStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
                        filled: true,
                        fillColor: context.dividerColor.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      style: context.bodyOneStyle.copyWith(
                        color: context.textPrimaryColor,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Images section
                    Text(
                      'review_images_label'.tr,
                      style: context.bodyOneStyle.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ImagePicker(
                      selectedImages: _selectedImages,
                      onAddImage: _addImage,
                      onRemoveImage: _removeImage,
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Submit button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                border: Border(
                  top: BorderSide(color: context.dividerColor, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'submit_review'.tr,
                    style: context.bodyOneStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== Hotel Header Widget =====
class _HotelHeader extends StatelessWidget {
  final String name;
  final String location;
  final String image;

  const _HotelHeader({
    required this.name,
    required this.location,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            image,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 80,
              height: 80,
              color: context.dividerColor,
              child: Icon(LucideIcons.hotel, color: context.textSecondaryColor),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: context.h5Style.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    LucideIcons.mapPin,
                    size: 14,
                    color: context.textSecondaryColor,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== Star Rating Widget =====
class _StarRating extends StatelessWidget {
  final int selectedRating;
  final ValueChanged<int> onRatingSelected;

  const _StarRating({
    required this.selectedRating,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final rating = index + 1;
        final isSelected = rating <= selectedRating;

        return GestureDetector(
          onTap: () => onRatingSelected(rating),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              isSelected ? Icons.star : Icons.star_border,
              size: 40,
              color: isSelected ? const Color(0xFFFFB800) : Colors.grey[400],
            ),
          ),
        );
      }),
    );
  }
}

// ===== Aspect Rating Widget =====
class _AspectRating extends StatelessWidget {
  final String label;
  final IconData icon;
  final int rating;
  final ValueChanged<int> onChanged;

  const _AspectRating({
    required this.label,
    required this.icon,
    required this.rating,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dividerColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: context.bodyOneStyle.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: List.generate(5, (index) {
              final starRating = index + 1;
              final isSelected = starRating <= rating;

              return GestureDetector(
                onTap: () => onChanged(starRating),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    size: 24,
                    color: isSelected
                        ? const Color(0xFFFFB800)
                        : Colors.grey[400],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ===== Image Picker Widget =====
class _ImagePicker extends StatelessWidget {
  final List<String> selectedImages;
  final VoidCallback onAddImage;
  final ValueChanged<int> onRemoveImage;

  const _ImagePicker({
    required this.selectedImages,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ...selectedImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(image),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onRemoveImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        // Add image button
        if (selectedImages.length < 5)
          GestureDetector(
            onTap: onAddImage,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: context.dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.dividerColor,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.plus,
                    size: 32,
                    color: context.textSecondaryColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'add_photo'.tr,
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
