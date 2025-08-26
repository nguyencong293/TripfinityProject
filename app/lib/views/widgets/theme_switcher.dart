import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/localization_service.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ThemeModeTile extends StatelessWidget {
  const ThemeModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return ListTile(
          leading: Icon(
            _iconFor(themeProvider.themeMode),
            color: context.iconColor,
          ),
          title: Text(
            'settings_system_interface'.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          trailing: Icon(
            LucideIcons.chevronRight,
            color: context.iconDisabledColor,
          ),
          onTap: () => _showThemeSheet(context, themeProvider),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
        );
      },
    );
  }

  IconData _iconFor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings_brightness;
    }
  }

  void _showThemeSheet(BuildContext context, ThemeProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _themeOption(context, provider, AppThemeMode.system),
              _themeOption(context, provider, AppThemeMode.light),
              _themeOption(context, provider, AppThemeMode.dark),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _themeOption(
    BuildContext context,
    ThemeProvider provider,
    AppThemeMode mode,
  ) {
    final isSelected = provider.themeMode == mode;
    return ListTile(
      leading: Icon(_iconFor(mode), color: context.iconColor),
      title: Text(_label(mode).tr, style: context.bodyOneStyle),
      trailing: isSelected
          ? Icon(Icons.check, color: context.primaryColor)
          : null,
      onTap: () async {
        await provider.setThemeMode(mode);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }

  String _label(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
    }
  }
}
