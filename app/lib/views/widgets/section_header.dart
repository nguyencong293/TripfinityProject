import 'package:flutter/material.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/config/theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: (padding as EdgeInsets).copyWith(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            InkWell(
              onTap: onAction,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  actionLabel!,
                  style: context.bodyOneStyle.copyWith(
                    color: context.textPrimaryColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
