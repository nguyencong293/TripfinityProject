import 'package:app/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';
import '../../services/localization_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageController>(
      builder: (context, lang, _) {
        return ListTile(
          leading: Icon(LucideIcons.languages, color: context.iconColor),
          title: Text(
            'settings_language'.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          trailing: Icon(
            LucideIcons.chevronRight,
            color: context.iconDisabledColor,
          ),
          onTap: () => _openSheet(context, lang),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
        );
      },
    );
  }

  void _openSheet(BuildContext context, LanguageController lang) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: lang.languages.entries.map((e) {
              final code = e.key;
              final name = e.value['name']!;
              final flag = e.value['flag']!;
              final isSelected = code == lang.currentLanguage;
              return ListTile(
                leading: Text(flag, style: const TextStyle(fontSize: 22)),
                title: Text(name),
                trailing: isSelected
                    ? Icon(Icons.check, color: context.iconColor)
                    : const SizedBox(),
                onTap: () async {
                  await lang.changeLanguage(code);
                  if (context.mounted) Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
