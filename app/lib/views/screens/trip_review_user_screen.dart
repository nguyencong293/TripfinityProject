import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/services/localization_service.dart';
import 'detail_trip_review_user_screen.dart';

class TripReviewUserScreen extends StatefulWidget {
  const TripReviewUserScreen({super.key});

  @override
  State<TripReviewUserScreen> createState() => _TripReviewUserScreenState();
}

class _TripReviewUserScreenState extends State<TripReviewUserScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, dynamic>> _reviewPlaces = [
    {
      'id': 1,
      'name': 'Nha Trang',
      'location': 'Việt Nam, Châu á',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'id': 2,
      'name': 'Nha Trang Xưa',
      'location': 'Nha Trang, Việt Nam',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'id': 3,
      'name': 'White Rose Restaurant',
      'location': 'Nha Trang, Việt Nam',
      'image': 'assets/images/onboarding3.png',
    },
    {
      'id': 4,
      'name': 'Vinpear - Resort Nha Trang',
      'location': 'Nha Trang, Việt Nam',
      'image': 'assets/images/onboarding4.png',
    },
  ];

  List<Map<String, dynamic>> _filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    _filteredPlaces = _reviewPlaces;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPlaces(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlaces = _reviewPlaces;
      } else {
        _filteredPlaces = _reviewPlaces
            .where(
              (place) =>
                  place['name']!.toLowerCase().contains(query.toLowerCase()) ||
                  place['location']!.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'reviews_title'.tr,
          style: context.h4Style.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: context.dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: context.bodyOneStyle.copyWith(
                    color: context.textPrimaryColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'search_places_hint'.tr,
                    hintStyle: context.bodyOneStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                    prefixIcon: Icon(
                      LucideIcons.search,
                      color: context.textSecondaryColor,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onChanged: _filterPlaces,
                ),
              ),
            ),

            // Places list
            Expanded(
              child: _filteredPlaces.isEmpty
                  ? _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _filteredPlaces.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final place = _filteredPlaces[index];
                        return _ReviewPlaceCard(
                          name: place['name']!,
                          location: place['location']!,
                          image: place['image']!,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DetailTripReviewUserScreen(
                                  placeName: place['name']!,
                                  placeLocation: place['location']!,
                                  placeImage: place['image']!,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewPlaceCard extends StatelessWidget {
  final String name;
  final String location;
  final String image;
  final VoidCallback onTap;

  const _ReviewPlaceCard({
    required this.name,
    required this.location,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.dividerColor.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
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
                        style: context.subTitleOneStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.textPrimaryColor,
                        ),
                        maxLines: 1,
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
                Icon(
                  LucideIcons.chevronRight,
                  color: context.textSecondaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.search,
                size: 48,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'no_places_found'.tr,
              style: context.h5Style.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'try_different_search'.tr,
              style: context.bodyTwoStyle.copyWith(
                color: context.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
