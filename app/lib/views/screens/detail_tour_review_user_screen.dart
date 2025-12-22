import 'dart:io';

import 'package:app/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/tour_api_service.dart';
import 'package:app/services/review_api_service.dart';

class DetailTourReviewUserScreen extends StatefulWidget {
  final int tourId;
  final String tourName;
  final String? tourImage;

  const DetailTourReviewUserScreen({
    super.key,
    required this.tourId,
    required this.tourName,
    this.tourImage,
  });

  @override
  State<DetailTourReviewUserScreen> createState() =>
      _DetailTourReviewUserScreenState();
}

class _DetailTourReviewUserScreenState
    extends State<DetailTourReviewUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  int _overallRating = 5;
  int _guideQualityRating = 5;
  int _itineraryQualityRating = 5;
  int _valueForMoneyRating = 5;
  int _organizationRating = 5;
  int _safetyRating = 5;

  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;
  bool _showAspectRatings = false;

  late TourApiService _tourApi;
  // ignore: unused_field
  late ReviewApiService _reviewApi;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _initServices() async {
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();

    _tourApi = TourApiService(dio: dio, prefs: prefs);
    _reviewApi = ReviewApiService(dio: dio, prefs: prefs);
    _userId = prefs.getInt('user_id');

    if (_userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá')),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (images.isNotEmpty) {
      setState(() {
        // Limit to 5 images
        final remaining = 5 - _selectedImages.length;
        if (remaining > 0) {
          _selectedImages.addAll(images.take(remaining));
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Upload images first
      final imageUrls = <String>[];
      for (final image in _selectedImages) {
        final url = await _tourApi.uploadReviewImage(image.path);
        imageUrls.add(url);
      }

      // Create the review
      await _tourApi.createTourReview(
        tourId: widget.tourId,
        userId: _userId!,
        rating: _overallRating,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrls: imageUrls,
        aspects: {
          'guideQuality': _guideQualityRating,
          'itineraryQuality': _itineraryQualityRating,
          'valueForMoney': _valueForMoneyRating,
          'organization': _organizationRating,
          'safety': _safetyRating,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh giá của bạn đã được gửi thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      debugPrint('Error submitting review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Viết đánh giá',
          style: TextStyle(color: context.textPrimaryColor),
        ),
        backgroundColor: context.backgroundColor,
        iconTheme: IconThemeData(color: context.textPrimaryColor),
        elevation: 1,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tour info card
            _buildTourInfoCard(),
            const SizedBox(height: 24),

            // Overall rating
            _buildOverallRatingSection(),
            const SizedBox(height: 24),

            // Aspect ratings (collapsible)
            _buildAspectRatingsSection(),
            const SizedBox(height: 24),

            // Review title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề đánh giá',
                hintText: 'Tóm tắt trải nghiệm của bạn',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tiêu đề đánh giá';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Review content
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'Nội dung đánh giá',
                hintText: 'Chia sẻ chi tiết trải nghiệm của bạn...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập nội dung đánh giá';
                }
                if (value.trim().length < 20) {
                  return 'Nội dung đánh giá quá ngắn (tối thiểu 20 ký tự)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Image picker
            _buildImagePickerSection(),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Gửi đánh giá',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTourInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: widget.tourImage != null
                  ? Image.network(
                      widget.tourImage!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[300],
                        child: const Icon(Icons.tour),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[300],
                      child: const Icon(Icons.tour),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Đánh giá tour',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.tourName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRatingSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Đánh giá tổng thể',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getRatingLabel(_overallRating),
              style: TextStyle(
                fontSize: 14,
                color: _getRatingColor(_overallRating),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => _overallRating = index + 1),
                  icon: Icon(
                    index < _overallRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAspectRatingsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                setState(() => _showAspectRatings = !_showAspectRatings),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Đánh giá chi tiết (tùy chọn)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Icon(
                    _showAspectRatings
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                ],
              ),
            ),
          ),
          if (_showAspectRatings) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAspectRatingRow(
                    'Chất lượng hướng dẫn',
                    Icons.person,
                    _guideQualityRating,
                    (v) => setState(() => _guideQualityRating = v),
                  ),
                  _buildAspectRatingRow(
                    'Chất lượng lịch trình',
                    Icons.schedule,
                    _itineraryQualityRating,
                    (v) => setState(() => _itineraryQualityRating = v),
                  ),
                  _buildAspectRatingRow(
                    'Giá trị',
                    Icons.attach_money,
                    _valueForMoneyRating,
                    (v) => setState(() => _valueForMoneyRating = v),
                  ),
                  _buildAspectRatingRow(
                    'Tổ chức',
                    Icons.business_center,
                    _organizationRating,
                    (v) => setState(() => _organizationRating = v),
                  ),
                  _buildAspectRatingRow(
                    'An toàn',
                    Icons.security,
                    _safetyRating,
                    (v) => setState(() => _safetyRating = v),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAspectRatingRow(
    String label,
    IconData icon,
    int rating,
    ValueChanged<int> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onChanged(index + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Thêm hình ảnh (tối đa 5)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${_selectedImages.length}/5',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // Add image button
              if (_selectedImages.length < 5)
                InkWell(
                  onTap: _pickImages,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 32,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thêm ảnh',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Selected images
              ..._selectedImages.asMap().entries.map((entry) {
                final index = entry.key;
                final image = entry.value;
                return Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(image.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
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
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Rất tệ';
      case 2:
        return 'Tệ';
      case 3:
        return 'Bình thường';
      case 4:
        return 'Tốt';
      case 5:
        return 'Tuyệt vời';
      default:
        return '';
    }
  }

  Color _getRatingColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
