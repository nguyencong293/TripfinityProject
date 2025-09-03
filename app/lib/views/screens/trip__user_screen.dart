import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/services/localization_service.dart';

import 'detail_trip_user_screen.dart';

class TripUserScreen extends StatelessWidget {
  const TripUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      floatingActionButton: _AddTripFab(
        onPressed: () {
          // TODO: open "create trip" flow
        },
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'trips_title'.tr,
                style: context.h4Style.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Active trip card
              _TripCard(
                title: 'da_nang_trip'.tr,
                coverAsset: 'assets/images/onboarding1.png',
                dateRangeText: '12 thg 6 — 20 thg 6 , 2025',
                savedCount: 6,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DetailTripUserScreen(),
                    ),
                  );
                },
                onEdit: () => _showEditTripSheet(context),
              ),

              const SizedBox(height: 20),

              // Completed trips section (placeholder)
              Text(
                'completed_trips'.tr,
                style: context.subTitleTwoStyle.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'completed_trips_hint'.tr,
                style: context.bodyTwoStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTripSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: false,
      backgroundColor: context.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    const SizedBox(width: 32), // balance close btn at right
                    Expanded(
                      child: Center(
                        child: Text(
                          'edit_trip'.tr,
                          style: context.subTitleTwoStyle.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.textPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: context.dividerColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          LucideIcons.x,
                          color: context.textPrimaryColor,
                          size: 20,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 1,
                color: context.dividerColor.withValues(alpha: 0.2),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    LucideIcons.calendarClock,
                    color: context.primaryColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  'edit_time'.tr,
                  style: context.bodyOneStyle.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Icon(
                  LucideIcons.chevronRight,
                  color: context.textSecondaryColor,
                  size: 20,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: open your edit-time flow
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    LucideIcons.trash2,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
                title: Text(
                  'cancel_trip'.tr,
                  style: context.bodyOneStyle.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(
                  LucideIcons.chevronRight,
                  color: Colors.red,
                  size: 20,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  // TODO: confirm & cancel the trip
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _TripCard extends StatelessWidget {
  final String title;
  final String coverAsset;
  final String dateRangeText;
  final int savedCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _TripCard({
    required this.title,
    required this.coverAsset,
    required this.dateRangeText,
    required this.savedCount,
    required this.onTap,
    required this.onEdit,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(coverAsset, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.subTitleOneStyle.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 16,
                          color: context.textSecondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            dateRangeText,
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.heart,
                          size: 16,
                          color: context.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$savedCount ${'saved_count_suffix'.tr}',
                          style: context.captionStyle.copyWith(
                            color: context.textSecondaryColor,
                          ),
                        ),
                        const Spacer(),
                        // Edit button with proper styling
                        Container(
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onEdit,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.pencil,
                                      size: 16,
                                      color: context.primaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'edit'.tr,
                                      style: context.captionStyle.copyWith(
                                        color: context.primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddTripFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddTripFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.3)),
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
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(27),
          child: Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            child: Icon(
              LucideIcons.plus,
              color: context.primaryColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
