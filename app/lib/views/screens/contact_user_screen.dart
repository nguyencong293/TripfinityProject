import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';

class ContactUserScreen extends StatefulWidget {
  const ContactUserScreen({super.key});

  @override
  State<ContactUserScreen> createState() => _ContactUserScreenState();
}

class _ContactUserScreenState extends State<ContactUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('contact_sent_success'.tr)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'contact_title'.tr,
                      style: context.h4Style.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: context.cardBackgroundColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        LucideIcons.x,
                        color: context.textPrimaryColor,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      tooltip: 'cancel'.tr,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Intro
              Text(
                'contact_intro'.tr,
                style: context.bodyOneStyle.copyWith(
                  color: context.textSecondaryColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              // Info card
              Container(
                decoration: BoxDecoration(
                  color: context.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.dividerColor.withValues(alpha: .18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoItem(
                      emoji: '📧',
                      title: 'contact_email'.tr,
                      value: 'contact_email_value'.tr,
                      iconColor: context.primaryColor,
                    ),
                    const SizedBox(height: 10),
                    _InfoItem(
                      emoji: '📞',
                      title: 'contact_hotline'.tr,
                      value: 'contact_hotline_value'.tr,
                      iconColor: context.successColor,
                    ),
                    const SizedBox(height: 10),
                    _InfoItem(
                      emoji: '📍',
                      title: 'contact_office'.tr,
                      value: 'contact_office_address'.tr,
                      iconColor: context.warningAlertColor,
                      multiline: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Map preview (static styled box)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: context.cardBackgroundColor,
                      child: CustomPaint(
                        painter: _MapGridPainter(
                          color: context.dividerColor.withValues(alpha: .35),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              color: context.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'contact_map_preview'.tr,
                              style: context.bodyOneStyle.copyWith(
                                color: context.textSecondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledField(
                      label: 'contact_full_name_label'.tr,
                      hint: 'contact_full_name_hint'.tr,
                      controller: _nameCtrl,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'name_required'.tr
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
                      label: 'contact_email_label'.tr,
                      hint: 'contact_email_hint'.tr,
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return 'email_required'.tr;
                        final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(s);
                        return ok ? null : 'email_invalid'.tr;
                      },
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
                      label: 'contact_subject_label'.tr,
                      hint: 'contact_subject_hint'.tr,
                      controller: _subjectCtrl,
                    ),
                    const SizedBox(height: 14),
                    _LabeledField(
                      label: 'contact_message_label'.tr,
                      hint: 'contact_message_hint'.tr,
                      controller: _messageCtrl,
                      maxLines: 6,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'enter_message_required'.tr
                          : null,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'contact_send'.tr,
                          style: context.subTitleTwoStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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

class _InfoItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String value;
  final Color iconColor;
  final bool multiline;

  const _InfoItem({
    required this.emoji,
    required this.title,
    required this.value,
    required this.iconColor,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: context.subTitleTwoStyle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: context.bodyTwoStyle.copyWith(
                  color: context.textSecondaryColor,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _LabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: .35),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            style: context.bodyOneStyle.copyWith(
              color: context.textPrimaryColor,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: context.bodyOneStyle.copyWith(
                color: context.textSecondaryColor.withValues(alpha: .7),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final Color color;
  _MapGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 24.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
