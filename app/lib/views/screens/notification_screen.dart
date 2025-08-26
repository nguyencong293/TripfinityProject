import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';

/// A static Notification screen UI that follows app theme + localization
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPrimaryColor),
        title: Text('notifications_title'.tr, style: context.h5Style),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            _Tabs(),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: const [
                  _NotificationItem(
                    titleKey: 'notif_booking_success_title',
                    messageKey: 'notif_booking_success_message',
                    dateText: '12/6/2025',
                    unread: true,
                  ),
                  SizedBox(height: 12),
                  _NotificationItem(
                    titleKey: 'notif_booking_success_title',
                    messageKey: 'notif_booking_success_message',
                    dateText: '12/6/2025',
                    unread: true,
                  ),
                  SizedBox(height: 12),
                  _NotificationItem(
                    titleKey: 'notif_booking_success_title',
                    messageKey: 'notif_booking_success_message',
                    dateText: '12/6/2025',
                    unread: false,
                  ),
                  SizedBox(height: 12),
                  _NotificationItem(
                    titleKey: 'notif_booking_success_title',
                    messageKey: 'notif_booking_success_message',
                    dateText: '12/6/2025',
                    unread: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tabs extends StatefulWidget {
  @override
  State<_Tabs> createState() => _TabsState();
}

class _TabsState extends State<_Tabs> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      'notif_tab_all'.tr,
      'notif_tab_latest'.tr,
      'notif_tab_unread'.tr,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = index == i;
          return Padding(
            padding: EdgeInsets.only(right: i == tabs.length - 1 ? 0 : 8),
            child: ChoiceChip(
              label: Text(tabs[i]),
              selected: selected,
              onSelected: (_) => setState(() => index = i),
              labelStyle: selected
                  ? context.bodyOneStyle.copyWith(
                      color: context.buttonTextColor,
                    )
                  : context.bodyOneStyle,
              selectedColor: context.primaryColor,
              backgroundColor: context.cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: context.borderLineColor),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String titleKey;
  final String messageKey;
  final String dateText; // use localized date formatting later
  final bool unread;

  const _NotificationItem({
    required this.titleKey,
    required this.messageKey,
    required this.dateText,
    this.unread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: unread ? Colors.red : context.iconDisabledColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleKey.tr,
                  style: context.subTitleOneStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  messageKey.tr,
                  style: context.bodyTwoStyle.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    dateText,
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
