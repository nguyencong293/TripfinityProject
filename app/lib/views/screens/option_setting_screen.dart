import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';
import 'package:app/views/widgets/language_switcher.dart';
import 'package:app/views/widgets/theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Settings/Options screen: language + theme + currency (placeholder)
class OptionSettingScreen extends StatelessWidget {
  const OptionSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPrimaryColor),
        title: Text('account_settings'.tr, style: context.h5Style),
      ),
      backgroundColor: context.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _Section(children: [ThemeModeTile()]),
          const SizedBox(height: 12),
          _Section(children: [LanguageTile()]),
          const SizedBox(height: 12),
          _Section(
            children: [
              _SimpleNavTile(
                icon: LucideIcons.badgeDollarSign,
                title: 'currency'.tr,
                subtitle: 'currency_vnd'.tr,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final List<Widget> children;
  const _Section({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, color: context.borderLineColor),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SimpleNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _SimpleNavTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: context.iconColor),
      title: Text(title, style: context.subTitleOneStyle),
      subtitle: subtitle != null
          ? Text(subtitle!, style: context.bodyTwoStyle)
          : null,
      trailing: Icon(
        LucideIcons.chevronRight,
        color: context.iconDisabledColor,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }
}
