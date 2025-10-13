import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:app/services/hotel_booking_api_service.dart';

class HotelBookingCheckoutScreen extends StatefulWidget {
  final int hotelId;
  final String hotelTitle;
  final String? imageUrl;
  final num basePrice;
  final num? extraPricePerNight;
  final String? currencyCode;
  final DateTimeRange dateRange;
  final int rooms;
  final int people;

  const HotelBookingCheckoutScreen({
    super.key,
    required this.hotelId,
    required this.hotelTitle,
    this.imageUrl,
    required this.basePrice,
    this.extraPricePerNight,
    required this.currencyCode,
    required this.dateRange,
    required this.rooms,
    required this.people,
  });

  @override
  State<HotelBookingCheckoutScreen> createState() =>
      _HotelBookingCheckoutScreenState();
}

class _HotelBookingCheckoutScreenState
    extends State<HotelBookingCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _requestCtrl = TextEditingController();

  bool _submitting = false;
  int _rooms = 1;
  int _beds = 1;
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();
    _rooms = widget.rooms;
    _beds = 1;
    _dateRange = widget.dateRange;
  }

  Future<void> _openDateRangePicker() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: 'Chọn ngày',
      saveText: 'Xong',
    );
    if (picked != null) {
      setState(() {
        if (picked.end.isAtSameMomentAs(picked.start)) {
          _dateRange = DateTimeRange(
            start: picked.start,
            end: picked.start.add(const Duration(days: 1)),
          );
        } else {
          _dateRange = picked;
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _requestCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _rooms = _rooms.clamp(1, 99);
    _beds = _beds.clamp(1, 99);
    final nights = _dateRange.end
        .difference(_dateRange.start)
        .inDays
        .clamp(1, 365);
    num total = widget.basePrice * _rooms;
    if (widget.extraPricePerNight != null && nights > 1) {
      total += widget.extraPricePerNight! * _rooms * (nights - 1);
    } else {
      total *= nights;
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Thanh toán',
          style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _summaryCard(nights, total),
          const SizedBox(height: 12),
          _dateSelector(),
          const SizedBox(height: 12),
          _roomBedSelector(),
          const SizedBox(height: 12),
          _contactForm(),
          const SizedBox(height: 12),
          _policies(),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF23A455),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 0,
              ),
              onPressed: _submitting ? null : () => _submit(total),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Xác nhận đặt (chưa thanh toán)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(int nights, num total) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child:
                (widget.imageUrl != null && widget.imageUrl!.startsWith('http'))
                ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                : (widget.imageUrl != null
                      ? Image.asset(widget.imageUrl!, fit: BoxFit.cover)
                      : Icon(LucideIcons.image, color: context.primaryColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.hotelTitle,
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatDate(_dateRange.start)} → ${_formatDate(_dateRange.end)} · $_rooms phòng · ${widget.people} khách · $nights đêm',
                  style: context.captionStyle.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      _formatPrice(widget.basePrice, widget.currencyCode),
                      style: context.bodyOneStyle.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.extraPricePerNight != null)
                      Text(
                        ' + ${_formatPrice(widget.extraPricePerNight!, widget.currencyCode)} / đêm',
                        style: context.bodyOneStyle.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.orange,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Tổng: ${_formatPrice(total, widget.currencyCode)}',
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ngày nhận/trả phòng',
            style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _outlinedChip(
                  icon: LucideIcons.calendar,
                  label:
                      '${_formatDate(_dateRange.start)} → ${_formatDate(_dateRange.end)}',
                  onTap: _openDateRangePicker,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roomBedSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Số phòng & số giường',
            style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _qtyRow(
            label: 'Phòng',
            value: _rooms,
            onMinus: () => setState(() => _rooms = (_rooms - 1).clamp(1, 99)),
            onPlus: () => setState(() => _rooms = (_rooms + 1).clamp(1, 99)),
          ),
          const SizedBox(height: 8),
          _qtyRow(
            label: 'Giường',
            value: _beds,
            onMinus: () => setState(() => _beds = (_beds - 1).clamp(1, 99)),
            onPlus: () => setState(() => _beds = (_beds + 1).clamp(1, 99)),
          ),
        ],
      ),
    );
  }

  Widget _outlinedChip({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          border: Border.all(color: context.dividerColor),
          borderRadius: BorderRadius.circular(26),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: context.textPrimaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyRow({
    required String label,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: context.bodyTwoStyle.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        _qtyBtn(icon: LucideIcons.minus, onTap: onMinus),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$value',
            style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        _qtyBtn(icon: LucideIcons.plus, onTap: onPlus),
      ],
    );
  }

  Widget _qtyBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: context.dividerColor),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _contactForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin liên hệ',
            style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _field(
            'Họ và tên',
            _nameCtrl,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
          ),
          const SizedBox(height: 8),
          _field(
            'Email',
            _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
          ),
          const SizedBox(height: 8),
          _field(
            'Số điện thoại',
            _phoneCtrl,
            keyboardType: TextInputType.phone,
            validator: (v) => (v == null || v.trim().length < 8)
                ? 'Số điện thoại không hợp lệ'
                : null,
          ),
          const SizedBox(height: 8),
          _field(
            'Yêu cầu đặc biệt (tùy chọn)',
            _requestCtrl,
            maxLines: 3,
            validator: (_) => null,
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.captionStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: context.cardBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: context.dividerColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _policies() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chính sách',
          style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          '• Đặt chỗ sẽ ở trạng thái chờ thanh toán.\n• Bạn sẽ thanh toán qua ví/đối tác ở bước sau.',
          style: context.captionStyle.copyWith(
            color: context.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Future<void> _submit(num total) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid =
          prefs.getInt('user_id') ??
          int.tryParse(prefs.getString('user_id') ?? '') ??
          -1;
      if (uid <= 0) {
        _showSnack('Bạn cần đăng nhập để đặt phòng.');
        setState(() => _submitting = false);
        return;
      }

      final api = HotelBookingApiService(dio: Dio(), prefs: prefs);
      await api.createBooking(
        userId: uid,
        hotelId: widget.hotelId,
        startDate: DateTime(
          _dateRange.start.year,
          _dateRange.start.month,
          _dateRange.start.day,
        ),
        endDate: DateTime(
          _dateRange.end.year,
          _dateRange.end.month,
          _dateRange.end.day,
        ),
        numAdults: widget.people,
        totalPrice: total,
        currencyCode: (widget.currencyCode ?? 'VND').toUpperCase(),
        providerNotes: _buildProviderNotes(),
      );

      if (!mounted) return;
      setState(() => _submitting = false);
      _showSnack('Đặt chỗ thành công. Chờ thanh toán.');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showSnack('Lỗi đặt chỗ: ${e.toString()}');
    }
  }

  String _buildProviderNotes() {
    final parts = <String>[];
    parts.add('rooms=$_rooms');
    parts.add('beds=$_beds');
    final r = _requestCtrl.text.trim();
    if (r.isNotEmpty) parts.add('requests=${r.replaceAll('\n', ' ')}');
    return parts.join('; ');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.maybeOf(
      context,
    )?.showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _formatPrice(num price, String? currency) {
    final c = (currency ?? 'VND').toUpperCase();
    if (c == 'VND' || c == 'VNĐ') {
      final s = price.toStringAsFixed(0);
      final rev = s.split('').reversed.toList();
      final parts = <String>[];
      for (int i = 0; i < rev.length; i++) {
        if (i > 0 && i % 3 == 0) parts.add('.');
        parts.add(rev[i]);
      }
      final grouped = parts.reversed.join();
      return '$grouped đ';
    }
    return '$price $c';
  }
}
