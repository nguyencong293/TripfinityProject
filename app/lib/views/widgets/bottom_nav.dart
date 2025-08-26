import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/services/localization_service.dart';
import 'package:provider/provider.dart';
import 'package:app/controllers/language_controller.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageController>(
      builder: (context, lang, _) {
        final labels = [
          'nav_home'.tr,
          'nav_search'.tr,
          'nav_trips'.tr,
          'nav_reviews'.tr,
          'nav_account'.tr,
        ];
        final icons = const [
          LucideIcons.home,
          LucideIcons.search,
          LucideIcons.heart,
          LucideIcons.messageSquare,
          LucideIcons.user,
        ];

        return SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            items: List.generate(icons.length, (i) {
              return BottomNavigationBarItem(
                icon: Icon(icons[i]),
                label: labels[i],
              );
            }),
          ),
        );
      },
    );
  }
}
