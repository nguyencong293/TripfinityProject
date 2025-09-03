import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';

class TermsPolicieScreen extends StatelessWidget {
  const TermsPolicieScreen({super.key});

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
          'terms_policies_title'.tr,
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
              // 1. Điều khoản sử dụng
              _SectionTitle(number: "1.", title: 'terms_usage_title'.tr),
              const SizedBox(height: 12),

              _BulletPoint(text: 'terms_usage_point1'.tr),
              const SizedBox(height: 8),

              _BulletPoint(text: 'terms_usage_point2'.tr),
              const SizedBox(height: 8),

              // Sub-bullets cho điểm 2
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Column(
                  children: [
                    _SubBulletPoint(text: 'terms_usage_sub1'.tr),
                    const SizedBox(height: 6),
                    _SubBulletPoint(text: 'terms_usage_sub2'.tr),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              _BulletPoint(text: 'terms_usage_point3'.tr),

              const SizedBox(height: 24),

              // 2. Chính sách quyền riêng tư
              _SectionTitle(number: "2.", title: 'privacy_policy_title'.tr),
              const SizedBox(height: 12),

              _BulletPoint(text: 'privacy_point1'.tr),
              const SizedBox(height: 8),

              _BulletPoint(text: 'privacy_point2'.tr),

              const SizedBox(height: 24),

              // 3. Chính sách bản quyền
              _SectionTitle(number: "3.", title: 'copyright_policy_title'.tr),
              const SizedBox(height: 12),

              _BulletPoint(text: 'copyright_point1'.tr),
              const SizedBox(height: 8),

              _BulletPoint(text: 'copyright_point2'.tr),

              const SizedBox(height: 24),

              // 4. Chính sách miễn trừ trách nhiệm
              _SectionTitle(number: "4.", title: 'disclaimer_policy_title'.tr),
              const SizedBox(height: 12),

              _BulletPoint(text: 'disclaimer_point1'.tr),
              const SizedBox(height: 8),

              _BulletPoint(text: 'disclaimer_point2'.tr),

              const SizedBox(height: 24),

              // 5. Liên hệ hỗ trợ
              _SectionTitle(number: "5.", title: 'support_contact_title'.tr),
              const SizedBox(height: 12),

              _BulletPoint(text: 'support_contact_text'.tr),

              const SizedBox(height: 32),

              // Footer notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 24,
                      color: context.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'terms_footer_notice'.tr,
                      style: context.bodyTwoStyle.copyWith(
                        color: context.textSecondaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.justify,
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

class _SectionTitle extends StatelessWidget {
  final String number;
  final String title;

  const _SectionTitle({required this.number, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: context.h5Style.copyWith(
            fontWeight: FontWeight.bold,
            color: context.textPrimaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: context.h5Style.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

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
            color: context.textPrimaryColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: context.bodyOneStyle.copyWith(
              color: context.textPrimaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}

class _SubBulletPoint extends StatelessWidget {
  final String text;

  const _SubBulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 4,
          margin: const EdgeInsets.only(top: 9),
          decoration: BoxDecoration(
            color: context.textSecondaryColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: context.bodyTwoStyle.copyWith(
              color: context.textSecondaryColor,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
