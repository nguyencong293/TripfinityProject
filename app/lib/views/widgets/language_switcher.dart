import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';


class LanguageDropdownCard extends StatelessWidget {
  final double? width;
  final bool showIcon;

  const LanguageDropdownCard({super.key, this.width, this.showIcon = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageController>(
      builder: (context, langController, child) {
        return Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: langController.currentLanguage,
              onChanged: (String? value) async {
                if (value != null) {
                  await langController.changeLanguage(value);
                  // ↑ đảm bảo AppLocalization.load xong rồi mới notifyListeners()
                }
              },
              items: langController.languages.entries.map((entry) {
                final isSelected = langController.currentLanguage == entry.key;
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showIcon) ...[
                        Text(
                          entry.value['flag']!,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        entry.value['name']!,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
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
}
