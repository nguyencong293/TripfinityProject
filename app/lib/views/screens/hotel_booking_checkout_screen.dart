import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:app/services/hotel_booking_api_service.dart';
import 'package:app/services/zalopay_api_service.dart';
import 'package:app/views/screens/payment_webview_screen.dart';

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
  final int? minParticipants;
  final int? maxParticipants;
  final int? maxBedsPerRoom; // from backend: max beds per room
  final int? maxRooms; // capacity (rooms)

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
    this.minParticipants,
    this.maxParticipants,
    this.maxBedsPerRoom,
    this.maxRooms,
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
  String _paymentMethod = 'counter'; // 'counter' or 'zalopay'
  int _rooms = 1;
  int _beds = 1;
  int _people = 1;
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();
    _rooms = widget.rooms;
    _beds = 1;
    _people = widget.people;
    _dateRange = widget.dateRange;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name =
          prefs.getString('user_name') ?? prefs.getString('full_name') ?? '';
      final email =
          prefs.getString('user_email') ?? prefs.getString('email') ?? '';
      final phone =
          prefs.getString('user_phone') ??
          prefs.getString('phone_number') ??
          '';

      if (mounted) {
        setState(() {
          _nameCtrl.text = name;
          _emailCtrl.text = email;
          _phoneCtrl.text = phone;
        });
      }
    } catch (e) {
      // Silent fail - user can input manually
    }
  }

  Future<void> _updateUserInfoIfNeeded(
    SharedPreferences prefs,
    int userId,
  ) async {
    try {
      final savedName =
          prefs.getString('user_name') ?? prefs.getString('full_name') ?? '';
      final savedPhone =
          prefs.getString('user_phone') ??
          prefs.getString('phone_number') ??
          '';

      final newName = _nameCtrl.text.trim();
      final newPhone = _phoneCtrl.text.trim();

      // Check if name or phone changed
      if (newName != savedName || newPhone != savedPhone) {
        // Update backend
        final dio = Dio();
        dio.options.baseUrl = 'http://10.0.2.2:8080/api';
        final token = prefs.getString('user_token');
        if (token != null) {
          dio.options.headers['Authorization'] = 'Bearer $token';
        }

        await dio.put(
          '/users/$userId',
          data: {
            if (newName.isNotEmpty && newName != savedName)
              'full_name': newName,
            if (newPhone.isNotEmpty && newPhone != savedPhone)
              'phone_number': newPhone,
          },
        );

        // Update SharedPreferences
        if (newName != savedName) {
          await prefs.setString('user_name', newName);
          await prefs.setString('full_name', newName);
        }
        if (newPhone != savedPhone) {
          await prefs.setString('user_phone', newPhone);
          await prefs.setString('phone_number', newPhone);
        }
      }
    } catch (e) {
      // Silent fail - don't block booking if user update fails
      print('Failed to update user info: $e');
    }
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
    final nights = _calcNights(_dateRange);
    // Công thức người dùng yêu cầu:
    // Tổng = số phòng × (giá gốc + số đêm × giá mỗi đêm)
    final extra = (widget.extraPricePerNight ?? 0);
    final perRoomTotal = widget.basePrice + nights * extra;
    final total = _rooms * perRoomTotal;

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
          _peopleSelector(),
          const SizedBox(height: 12),
          _contactForm(),
          const SizedBox(height: 12),
          _policies(),
          const SizedBox(height: 12),
          _paymentMethodSelector(),
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
                  : Text(
                      _paymentMethod == 'counter'
                          ? 'Xác nhận đặt (trả tại quầy)'
                          : 'Thanh toán qua ZaloPay',
                      style: const TextStyle(
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

  Widget _paymentMethodSelector() {
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
            'Phương thức thanh toán',
            style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          RadioListTile<String>(
            value: 'counter',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v ?? 'counter'),
            title: const Text('Thanh toán trực tiếp tại quầy'),
          ),
          RadioListTile<String>(
            value: 'zalopay',
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v ?? 'zalopay'),
            title: const Text('Thanh toán qua ZaloPay (sandbox)'),
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
                  '${_formatDate(_dateRange.start)} → ${_formatDate(_dateRange.end)} · $_rooms phòng · $_people khách · $nights đêm',
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
            onMinus: () => setState(() {
              final minR = 1;
              final maxR = (widget.maxRooms ?? 99).clamp(1, 999);
              _rooms = (_rooms - 1).clamp(minR, maxR);
              // Clamp beds when rooms changes
              final maxBeds = (widget.maxBedsPerRoom ?? 99) * _rooms;
              _beds = _beds.clamp(1, maxBeds.clamp(1, 999));
            }),
            onPlus: () => setState(() {
              final minR = 1;
              final maxR = (widget.maxRooms ?? 99).clamp(1, 999);
              _rooms = (_rooms + 1).clamp(minR, maxR);
              final maxBeds = (widget.maxBedsPerRoom ?? 99) * _rooms;
              _beds = _beds.clamp(1, maxBeds.clamp(1, 999));
            }),
          ),
          const SizedBox(height: 8),
          _qtyRow(
            label: 'Giường',
            value: _beds,
            onMinus: () => setState(() {
              final maxBeds = (widget.maxBedsPerRoom ?? 99) * _rooms;
              _beds = (_beds - 1).clamp(1, maxBeds.clamp(1, 999));
            }),
            onPlus: () => setState(() {
              final maxBeds = (widget.maxBedsPerRoom ?? 99) * _rooms;
              _beds = (_beds + 1).clamp(1, maxBeds.clamp(1, 999));
            }),
          ),
        ],
      ),
    );
  }

  Widget _peopleSelector() {
    final minP = (widget.minParticipants ?? 1).clamp(1, 9999);
    final maxP = (widget.maxParticipants ?? 9999).clamp(minP, 9999);
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
            'Số khách',
            style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _qtyRow(
            label: 'Khách',
            value: _people,
            onMinus: () => setState(() {
              _people = (_people - 1).clamp(minP, maxP);
            }),
            onPlus: () => setState(() {
              _people = (_people + 1).clamp(minP, maxP);
            }),
          ),
          const SizedBox(height: 6),
          Text(
            'Tối thiểu $minP · Tối đa $maxP',
            style: context.captionStyle.copyWith(
              color: context.textSecondaryColor,
            ),
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
            readOnly: true, // Email cannot be changed
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
    bool readOnly = false,
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
          readOnly: readOnly,
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

      // Update user info if name or phone changed
      await _updateUserInfoIfNeeded(prefs, uid);

      // COUNTER payment: Create booking immediately
      if (_paymentMethod == 'counter') {
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
          numAdults: _people,
          totalPrice: total,
          currencyCode: (widget.currencyCode ?? 'VND').toUpperCase(),
          providerNotes: _buildProviderNotes(),
          paymentMethod: 'counter', // Important: specify payment method
        );
        if (!mounted) return;
        setState(() => _submitting = false);
        _showSnack('Đặt chỗ thành công. Thanh toán tại quầy khi nhận phòng.');
        Navigator.of(context).pop();
        return;
      }

      // ZALOPAY payment: Do NOT create booking yet, just create order
      try {
        final zalo = ZaloPayApiService(dio: Dio(), prefs: prefs);
        final orderResult = await zalo.createOrder(
          amount: total,
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
          numAdults: _people,
          numChildren: 0,
          providerNotes:
              _buildProviderNotes(), // Include provider notes (rooms, beds, requests)
          description: 'Thanh toan dat phong hotel #${widget.hotelId}',
        );

        final orderUrl = orderResult['order_url']!;
        final appTransId =
            orderResult['apptransid']!; // Note: lowercase from backend

        setState(() => _submitting = false);

        // Open WebView for payment
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentWebViewScreen(url: orderUrl),
          ),
        );

        if (result == true) {
          // Payment completed successfully - now create booking via test endpoint
          setState(() => _submitting = true);
          try {
            // Call test endpoint to create booking from pending payment
            final testDio = Dio();
            testDio.options.baseUrl = 'http://10.0.2.2:8080/api';
            final token = prefs.getString('user_token');
            if (token != null) {
              testDio.options.headers['Authorization'] = 'Bearer $token';
            }

            final createResponse = await testDio.post(
              '/test/create-booking-from-pending',
              queryParameters: {'appTransId': appTransId},
            );

            setState(() => _submitting = false);

            if (createResponse.statusCode == 200 &&
                createResponse.data is Map &&
                (createResponse.data as Map)['success'] == true) {
              // Booking created successfully
              final bookingId = (createResponse.data as Map)['bookingId'];
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 32),
                        SizedBox(width: 12),
                        Text('Thanh toán thành công!'),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đặt phòng của bạn đã được xác nhận.'),
                        if (bookingId != null)
                          Text(
                            'Mã đặt phòng: #$bookingId',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        SizedBox(height: 8),
                        Text(
                          'Bạn có thể kiểm tra chi tiết đặt phòng trong mục "Đơn của tôi".',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Close checkout screen
                        },
                        child: Text('Đóng'),
                      ),
                    ],
                  ),
                );
              }
            } else {
              // Failed to create booking
              _showSnack(
                'Thanh toán thành công nhưng không tạo được đặt phòng. Vui lòng liên hệ hỗ trợ.',
              );
            }
          } catch (e) {
            setState(() => _submitting = false);
            _showSnack(
              'Thanh toán thành công nhưng lỗi tạo đặt phòng: ${e.toString()}',
            );
          }
        } else {
          // Payment cancelled or failed
          _showSnack('Thanh toán chưa hoàn tất. Vui lòng thử lại nếu cần.');
        }
      } catch (e) {
        setState(() => _submitting = false);
        _showSnack('Không tạo được đơn ZaloPay: ${e.toString()}');
      }
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
  int _calcNights(DateTimeRange range) {
    // Normalize to midnight to avoid any time component affecting inDays
    final s = DateTime(range.start.year, range.start.month, range.start.day);
    final e = DateTime(range.end.year, range.end.month, range.end.day);
    final diff = e.difference(s).inDays;
    return diff <= 0 ? 1 : diff; // at least 1 night
  }

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
