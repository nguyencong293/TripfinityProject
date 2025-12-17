import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:app/services/tour_booking_api_service.dart';
import 'package:app/services/zalopay_api_service.dart';
import 'package:app/services/user_interaction_service.dart';
import 'package:app/services/user_service.dart';
import 'package:app/views/screens/payment_webview_screen.dart';

class TourBookingCheckoutScreen extends StatefulWidget {
  final int tourId;
  final String tourTitle;
  final String? imageUrl;
  final num basePrice;
  final String? currencyCode;
  final DateTimeRange dateRange;
  final int people;
  final int? minParticipants;
  final int? maxParticipants;

  const TourBookingCheckoutScreen({
    super.key,
    required this.tourId,
    required this.tourTitle,
    this.imageUrl,
    required this.basePrice,
    required this.currencyCode,
    required this.dateRange,
    required this.people,
    this.minParticipants,
    this.maxParticipants,
  });

  @override
  State<TourBookingCheckoutScreen> createState() =>
      _TourBookingCheckoutScreenState();
}

class _TourBookingCheckoutScreenState extends State<TourBookingCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _requestCtrl = TextEditingController();

  bool _submitting = false;
  String _paymentMethod = 'counter'; // 'counter' or 'zalopay'
  int _people = 1;
  late DateTimeRange _dateRange;

  @override
  void initState() {
    super.initState();
    _people = widget.people;
    _dateRange = widget.dateRange;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final authController = context.read<AuthController>();
      final userId = authController.currentUser?.userId;
      final token = authController.rawToken;

      // Gọi API để lấy đầy đủ thông tin user từ backend
      if (userId != null && token != null) {
        debugPrint('📥 Fetching full user info from API for userId=$userId');
        final userService = UserService(dio: Dio());
        final user = await userService.getUserById(userId, token);

        if (mounted) {
          setState(() {
            _nameCtrl.text = user.fullName;
            _emailCtrl.text = user.email;
            _phoneCtrl.text = user.phoneNumber ?? '';
          });
        }
        debugPrint('✅ Loaded user info from API: phone=${user.phoneNumber}');

        // Cập nhật AuthController với data mới nhất
        authController.updateCurrentUser(user);
      } else {
        // Fallback: Lấy từ AuthController nếu không có token/userId
        final user = authController.currentUser;
        if (user != null && mounted) {
          setState(() {
            _nameCtrl.text = user.fullName;
            _emailCtrl.text = user.email;
            _phoneCtrl.text = user.phoneNumber ?? '';
          });
        }
        debugPrint('⚠️ Loaded user info from AuthController (no API call)');
      }
    } catch (e) {
      debugPrint('❌ Error loading user info: $e');
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
        debugPrint('🔄 User info changed - updating...');
        debugPrint('  Old: name="$savedName", phone="$savedPhone"');
        debugPrint('  New: name="$newName", phone="$newPhone"');

        // Validate before update
        if (newName.isEmpty) {
          throw Exception('Tên không được để trống');
        }
        if (newPhone.isEmpty || newPhone.length < 8) {
          throw Exception('Số điện thoại không hợp lệ');
        }

        // Update backend
        final dio = Dio();
        dio.options.baseUrl = 'http://10.0.2.2:8080/api';
        final token = prefs.getString('user_token');
        if (token != null) {
          dio.options.headers['Authorization'] = 'Bearer $token';
        }

        final updateData = {
          if (newName.isNotEmpty && newName != savedName) 'fullName': newName,
          if (newPhone.isNotEmpty && newPhone != savedPhone)
            'phoneNumber': newPhone,
        };

        debugPrint('📤 Sending PUT /users/$userId with data: $updateData');

        final response = await dio.put('/users/$userId', data: updateData);

        debugPrint('📥 Response status: ${response.statusCode}');

        if (response.statusCode == 200) {
          debugPrint('✅ Backend update successful');
          // Update SharedPreferences only if backend update successful
          if (newName != savedName) {
            await prefs.setString('user_name', newName);
            await prefs.setString('full_name', newName);
          }
          if (newPhone != savedPhone) {
            await prefs.setString('user_phone', newPhone);
            await prefs.setString('phone_number', newPhone);
          }

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✓ Đã cập nhật thông tin liên hệ'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          debugPrint('✓ User info updated successfully');
        }
      }
    } catch (e) {
      // Show error but don't block booking
      debugPrint('Failed to update user info: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể cập nhật thông tin: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
    final days = _calcDays(_dateRange);
    // Tổng giá tour = giá cơ bản × số người
    final total = widget.basePrice * _people;

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
          _summaryCard(days, total),
          const SizedBox(height: 12),
          _dateSelector(),
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
                          ? 'Xác nhận đặt (trả trực tiếp)'
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
          RadioGroup<String>(
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v ?? 'counter'),
            child: Column(
              children: [
                ListTile(
                  leading: Radio<String>(value: 'counter'),
                  title: const Text('Thanh toán trực tiếp'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => setState(() => _paymentMethod = 'counter'),
                ),
                ListTile(
                  leading: Radio<String>(value: 'zalopay'),
                  title: const Text('Thanh toán qua ZaloPay (sandbox)'),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => setState(() => _paymentMethod = 'zalopay'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(int days, num total) {
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
                  widget.tourTitle,
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatDate(_dateRange.start)} → ${_formatDate(_dateRange.end)} · $_people khách · $days ngày',
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
                    Text(
                      ' / người',
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
            'Ngày bắt đầu/kết thúc tour',
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
            'Số khách tham gia',
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
          '• Đặt tour sẽ ở trạng thái chờ xác nhận.\n• Bạn sẽ thanh toán qua ví/đối tác hoặc trực tiếp.',
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
        _showSnack('Bạn cần đăng nhập để đặt tour.');
        setState(() => _submitting = false);
        return;
      }

      // Update user info if name or phone changed
      await _updateUserInfoIfNeeded(prefs, uid);

      // COUNTER payment: Create booking immediately
      if (_paymentMethod == 'counter') {
        final api = TourBookingApiService(dio: Dio(), prefs: prefs);
        await api.createBooking(
          userId: uid,
          tourId: widget.tourId,
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

        // 🔥 Track BOOK action for AI
        try {
          final trackingService = await UserInteractionService.create();
          await trackingService.recordBook(
            itemId: widget.tourId,
            itemType: 'tour',
          );
        } catch (e) {
          // Silent fail
        }

        if (!mounted) return;
        setState(() => _submitting = false);
        _showSnack('Đặt tour thành công. Thanh toán trực tiếp khi tham gia.');
        Navigator.of(context).pop();
        return;
      }

      // ZALOPAY payment: Do NOT create booking yet, just create order
      try {
        final zalo = ZaloPayApiService(dio: Dio(), prefs: prefs);
        final orderResult = await zalo.createTourOrder(
          amount: total,
          userId: uid,
          tourId: widget.tourId,
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
          providerNotes: _buildProviderNotes(),
          description: 'Thanh toan dat tour #${widget.tourId}',
        );

        final orderUrl = orderResult['order_url']!;
        final appTransId = orderResult['apptransid']!;

        setState(() => _submitting = false);

        if (!mounted) return;
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
            // Call test endpoint to create tour booking from pending payment
            final testDio = Dio();
            testDio.options.baseUrl = 'http://10.0.2.2:8080/api';
            final token = prefs.getString('user_token');
            if (token != null) {
              testDio.options.headers['Authorization'] = 'Bearer $token';
            }

            final createResponse = await testDio.post(
              '/test/create-tour-booking-from-pending',
              queryParameters: {'appTransId': appTransId},
            );

            setState(() => _submitting = false);

            if (createResponse.statusCode == 200 &&
                createResponse.data is Map &&
                (createResponse.data as Map)['success'] == true) {
              // Booking created successfully
              final bookingId = (createResponse.data as Map)['bookingId'];

              // 🔥 Track BOOK action for AI
              try {
                final trackingService = await UserInteractionService.create();
                await trackingService.recordBook(
                  itemId: widget.tourId,
                  itemType: 'tour',
                );
              } catch (e) {
                // Silent fail
              }

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
                        Text('Đặt tour của bạn đã được xác nhận.'),
                        if (bookingId != null)
                          Text(
                            'Mã đặt tour: #$bookingId',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        SizedBox(height: 8),
                        Text(
                          'Bạn có thể kiểm tra chi tiết đặt tour trong mục "Đơn của tôi".',
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
                'Thanh toán thành công nhưng không tạo được đặt tour. Vui lòng liên hệ hỗ trợ.',
              );
            }
          } catch (e) {
            setState(() => _submitting = false);
            _showSnack(
              'Thanh toán thành công nhưng lỗi tạo đặt tour: ${e.toString()}',
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
      _showSnack('Lỗi đặt tour: ${e.toString()}');
    }
  }

  String _buildProviderNotes() {
    final parts = <String>[];
    parts.add('people=$_people');
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

  int _calcDays(DateTimeRange range) {
    // Normalize to midnight to avoid any time component affecting inDays
    final s = DateTime(range.start.year, range.start.month, range.start.day);
    final e = DateTime(range.end.year, range.end.month, range.end.day);
    final diff = e.difference(s).inDays;
    return diff <= 0 ? 1 : diff; // at least 1 day
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
