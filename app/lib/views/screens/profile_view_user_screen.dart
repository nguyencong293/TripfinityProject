import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/controllers/language_controller.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../dto/user_dto.dart';

/// Profile details screen for user: follows theme + localization
class ProfileViewUserScreen extends StatelessWidget {
  const ProfileViewUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageController>(
      builder: (context, _, __) {
        final auth = context.watch<AuthController>();
        final user = auth.currentUser;

        String displayGender() {
          switch (user?.gender) {
            case Gender.male:
              return 'gender_male'.tr;
            case Gender.female:
              return 'gender_female'.tr;
            case Gender.other:
              return 'gender_other'.tr;
            default:
              return '-';
          }
        }

        String displayDob() {
          final dob = user?.dateOfBirth;
          if (dob == null) return '-';
          final d = dob.day.toString().padLeft(2, '0');
          final m = dob.month.toString().padLeft(2, '0');
          final y = dob.year.toString().padLeft(4, '0');
          return '$d/$m/$y';
        }

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 56,
            backgroundColor: context.backgroundColor,
            elevation: 0,
            iconTheme: IconThemeData(color: context.textPrimaryColor),
            title: Text('account_info'.tr, style: context.h5Style),
          ),
          backgroundColor: context.backgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: context.secondaryColor,
                        child: Text(
                          (user?.fullName.isNotEmpty == true
                              ? user!.fullName[0].toUpperCase()
                              : '?'),
                          style: context.h3Style,
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('feature_coming_soon'.tr)),
                          );
                        },
                        icon: const Icon(LucideIcons.camera),
                        label: Text('profile_edit_photo'.tr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _ProfileItem(
                    label: 'profile_full_name'.tr,
                    value: user?.fullName ?? '-',
                  ),
                  _ProfileItem(
                    label: 'profile_email'.tr,
                    value: user?.email ?? '-',
                  ),
                  _ProfileItem(
                    label: 'profile_phone'.tr,
                    value: user?.phoneNumber ?? '-',
                  ),
                  _ProfileItem(label: 'profile_dob'.tr, value: displayDob()),
                  _ProfileItem(
                    label: 'profile_gender'.tr,
                    value: displayGender(),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('feature_coming_soon'.tr)),
                        );
                      },
                      child: Text('profile_edit_account'.tr),
                    ),
                  ),
                  const SizedBox(height: 50),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: context.errorColor),
                          foregroundColor: context.errorColor,
                        ),
                        onPressed: () async {
                          // Capture messenger before the async gap to avoid using context after await
                          final messenger = ScaffoldMessenger.of(context);
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                title: Text('confirm_delete_title'.tr),
                                content: Text('confirm_delete_desc'.tr),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text('cancel'.tr),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(
                                      'delete'.tr,
                                      style: TextStyle(
                                        color: context.errorColor,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                          if (!context.mounted) return;
                          if (confirm == true) {
                            messenger.showSnackBar(
                              SnackBar(content: Text('feature_coming_soon'.tr)),
                            );
                          }
                        },
                        child: Text('profile_delete_account'.tr),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;
  const _ProfileItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: context.subTitleTwoStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: context.bodyOneStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
