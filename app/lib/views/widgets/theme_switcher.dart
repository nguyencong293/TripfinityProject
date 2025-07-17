import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';


/// Dropdown chọn theme mode
class ThemeModeDropdown extends StatelessWidget {
  final double? width;
  final bool showIcon;

  const ThemeModeDropdown({super.key, this.width, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.borderLineColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AppThemeMode>(
              value: themeProvider.themeMode,
              onChanged: (AppThemeMode? value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                }
              },
              items: AppThemeMode.values.map((AppThemeMode mode) {
                return DropdownMenuItem<AppThemeMode>(
                  value: mode,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showIcon) ...[
                        Icon(
                          _getIconForMode(mode),
                          size: 20,
                          color: context.iconColor,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        _getStringForMode(mode),
                        style: context.bodyOneStyle,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.settings_brightness;
    }
  }

  String _getStringForMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
}
