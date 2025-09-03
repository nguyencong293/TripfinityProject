import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';

class AboutTripfinityScreen extends StatelessWidget {
  const AboutTripfinityScreen({super.key});

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
        title: Text(
          'about_tripfinity'.tr,
          style: context.h4Style.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo và tên app
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: context.borderLineColor,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/logo_1.png',
                          height: 50,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tripfinity',
                      style: context.h3Style.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'app_tagline'.tr,
                      style: context.bodyOneStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Mô tả chính
              Text(
                'about_description_title'.tr,
                style: context.h5Style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 12),
              Text(
                'about_description_content'.tr,
                style: context.bodyOneStyle.copyWith(
                  color: context.textSecondaryColor,
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 32),

              // Tính năng chính
              Text(
                'key_features'.tr,
                style: context.h5Style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),

              _FeatureItem(
                icon: LucideIcons.mapPin,
                title: 'feature_location_title'.tr,
                description: 'feature_location_desc'.tr,
              ),
              const SizedBox(height: 16),

              _FeatureItem(
                icon: LucideIcons.activity,
                title: 'feature_community_title'.tr,
                description: 'feature_community_desc'.tr,
              ),
              const SizedBox(height: 16),

              _FeatureItem(
                icon: LucideIcons.calendar,
                title: 'feature_planning_title'.tr,
                description: 'feature_planning_desc'.tr,
              ),
              const SizedBox(height: 16),

              _FeatureItem(
                icon: LucideIcons.heart,
                title: 'feature_experience_title'.tr,
                description: 'feature_experience_desc'.tr,
              ),

              const SizedBox(height: 32),

              // Tại sao chọn Tripfinity
              Text(
                'why_choose_title'.tr,
                style: context.h5Style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),

              _WhyChooseItem(
                title: 'why_choose_reliability'.tr,
                description: 'why_choose_reliability_desc'.tr,
              ),
              const SizedBox(height: 12),

              _WhyChooseItem(
                title: 'why_choose_convenience'.tr,
                description: 'why_choose_convenience_desc'.tr,
              ),
              const SizedBox(height: 12),

              _WhyChooseItem(
                title: 'why_choose_localization'.tr,
                description: 'why_choose_localization_desc'.tr,
              ),
              const SizedBox(height: 12),

              _WhyChooseItem(
                title: 'why_choose_personalization'.tr,
                description: 'why_choose_personalization_desc'.tr,
              ),

              const SizedBox(height: 32),

              // Lời kết
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: 32,
                      color: context.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'closing_message'.tr,
                      style: context.bodyOneStyle.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Thông tin liên hệ
              Text(
                'contact_info'.tr,
                style: context.h5Style.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16),

              _ContactItem(
                icon: LucideIcons.mail,
                label: 'Email',
                value: 'contact@tripfinity.com',
              ),
              const SizedBox(height: 12),

              _ContactItem(
                icon: LucideIcons.globe,
                label: 'Website',
                value: 'www.tripfinity.com',
              ),
              const SizedBox(height: 12),

              _ContactItem(
                icon: LucideIcons.mapPin,
                label: 'office_address'.tr,
                value: 'Đà Nẵng, Việt Nam',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: context.primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.bodyOneStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: context.bodyTwoStyle.copyWith(
                  color: context.textSecondaryColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WhyChooseItem extends StatelessWidget {
  final String title;
  final String description;

  const _WhyChooseItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: context.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.bodyOneStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimaryColor,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: context.bodyTwoStyle.copyWith(
                  color: context.textSecondaryColor,
                  height: 1.4,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: context.textSecondaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: context.bodyTwoStyle.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: context.bodyTwoStyle.copyWith(
              color: context.textPrimaryColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
