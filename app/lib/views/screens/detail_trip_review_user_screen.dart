import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/services/localization_service.dart';

class DetailTripReviewUserScreen extends StatefulWidget {
  final String placeName;
  final String placeLocation;
  final String placeImage;

  const DetailTripReviewUserScreen({
    super.key,
    required this.placeName,
    required this.placeLocation,
    required this.placeImage,
  });

  @override
  State<DetailTripReviewUserScreen> createState() =>
      _DetailTripReviewUserScreenState();
}

class _DetailTripReviewUserScreenState
    extends State<DetailTripReviewUserScreen> {
  int _selectedRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final List<String> _selectedImages = [];

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

  void _addImage() {
    // Simulate adding image
    setState(() {
      _selectedImages.add(
        'assets/images/onboarding${(_selectedImages.length % 4) + 1}.png',
      );
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitReview() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('please_select_rating'.tr),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Simulate review submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('review_submitted_success'.tr),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
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
                    // Place header
                    _PlaceHeader(
                      name: widget.placeName,
                      location: widget.placeLocation,
                      image: widget.placeImage,
                    ),

                    const SizedBox(height: 32),

                    // Rating question
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

                    // Review title
                    Text(
                      'review_title_label'.tr,
                      style: context.bodyOneStyle.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ReviewTextField(
                      controller: _titleController,
                      hintText: 'review_title_hint'.tr,
                      maxLines: 2,
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
                    const SizedBox(height: 12),
                    _ReviewTextField(
                      controller: _reviewController,
                      hintText: 'review_content_hint'.tr,
                      maxLines: 6,
                    ),

                    const SizedBox(height: 24),

                    // Photos section
                    Text(
                      'add_photos_label'.tr,
                      style: context.bodyOneStyle.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _PhotosSection(
                      selectedImages: _selectedImages,
                      onAddImage: _addImage,
                      onRemoveImage: _removeImage,
                    ),

                    const SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),

            // Submit button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: context.dividerColor.withValues(alpha: 0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'submit_review'.tr,
                    style: context.subTitleTwoStyle.copyWith(
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

  String _getRatingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'rating_poor'.tr;
      case 2:
        return 'rating_fair'.tr;
      case 3:
        return 'rating_good'.tr;
      case 4:
        return 'rating_very_good'.tr;
      case 5:
        return 'rating_excellent'.tr;
      default:
        return '';
    }
  }
}

class _PlaceHeader extends StatelessWidget {
  final String name;
  final String location;
  final String image;

  const _PlaceHeader({
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
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 64,
                height: 64,
                color: context.primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  LucideIcons.image,
                  color: context.primaryColor,
                  size: 24,
                ),
              );
            },
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
                  fontWeight: FontWeight.w700,
                  color: context.textPrimaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                location,
                style: context.bodyTwoStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  final int selectedRating;
  final Function(int) onRatingSelected;

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
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              isSelected ? LucideIcons.star : LucideIcons.star,
              size: 40,
              color: isSelected
                  ? context.primaryColor
                  : context.iconDisabledColor.withValues(alpha: 0.5),
            ),
          ),
        );
      }),
    );
  }
}

class _ReviewTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _ReviewTextField({
    required this.controller,
    required this.hintText,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: context.bodyOneStyle.copyWith(color: context.textPrimaryColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: context.bodyOneStyle.copyWith(
            color: context.textSecondaryColor,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _PhotosSection extends StatelessWidget {
  final List<String> selectedImages;
  final VoidCallback onAddImage;
  final Function(int) onRemoveImage;

  const _PhotosSection({
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
        // Add photo button
        GestureDetector(
          onTap: onAddImage,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              LucideIcons.plus,
              color: context.textSecondaryColor,
              size: 24,
            ),
          ),
        ),
        // Selected images
        ...selectedImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  image,
                  width: 80,
                  height: 80,
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
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.x,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
