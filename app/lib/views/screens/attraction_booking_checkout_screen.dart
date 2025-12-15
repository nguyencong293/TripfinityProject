import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/controllers/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:app/services/attraction_booking_api_service.dart';
import 'package:app/services/zalopay_api_service.dart';
import 'package:app/services/user_interaction_service.dart';
import 'package:app/views/screens/payment_webview_screen.dart';

class AttractionBookingCheckoutScreen extends StatefulWidget {
  final int attractionId;
  final String attractionTitle;
  final String? imageUrl;
  final num basePrice;
  final String? currencyCode;
  final DateTime visitDate;
  final int people;
  final int? minParticipants;
  final int? maxParticipants;

  const AttractionBookingCheckoutScreen({
    super.key,
    required this.attractionId,
    required this.attractionTitle,
    this.imageUrl,
    required this.basePrice,
    required this.currencyCode,
    required this.visitDate,
    required this.people,
    this.minParticipants,
    this.maxParticipants,
  });

  @override
  State<AttractionBookingCheckoutScreen> createState() =>
      _AttractionBookingCheckoutScreenState();
}

class _AttractionBookingCheckoutScreenState
    extends State<AttractionBookingCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _requestCtrl = TextEditingController();

  bool _submitting = false;
  String _paymentMethod = 'counter'; // 'counter' or 'zalopay'
  int _people = 1;
  late DateTime _visitDate;

  @override
  void initState() {
    super.initState();
    _people = widget.people;
    _visitDate = widget.visitDate;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final authController = context.read<AuthController>();
      final user = authController.currentUser;

      if (user != null) {
        if (mounted) {
          setState(() {
            _nameCtrl.text = user.fullName;
            _emailCtrl.text = user.email;
            _phoneCtrl.text = user.phoneNumber ?? '';
          });
        }
        debugPrint('✅ Loaded user info from AuthController');
      } else {
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
        debugPrint('⚠️ Loaded user info from SharedPreferences (fallback)');
      }
    } catch (e) {
      debugPrint('❌ Error loading user info: $e');
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

      if (newName != savedName || newPhone != savedPhone) {
        debugPrint('🔄 User info changed - updating...');

        if (newName.isEmpty) {
          throw Exception('Tên không được để trống');
        }
        if (newPhone.isEmpty || newPhone.length < 8) {
          throw Exception('Số điện thoại không hợp lệ');
        }

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

        final response = await dio.put('/users/$userId', data: updateData);

        if (response.statusCode == 200) {
          if (newName != savedName) {
            await prefs.setString('user_name', newName);
            await prefs.setString('full_name', newName);
          }
          if (newPhone != savedPhone) {
            await prefs.setString('user_phone', newPhone);
            await prefs.setString('phone_number', newPhone);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✓ Đã cập nhật thông tin liên hệ'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } catch (e) {
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

  Future<void> _openDatePicker() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365 * 2)),
      helpText: 'Chọn ngày tham quan',
      cancelText: 'Hủy',
      confirmText: 'Xong',
    );
    if (picked != null) {
      setState(() {
        _visitDate = picked;
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
    final total = _people * widget.basePrice;

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
          _summaryCard(total),
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
          RadioGroup<String>(
            groupValue: _paymentMethod,
            onChanged: (v) => setState(() => _paymentMethod = v ?? 'counter'),
            child: Column(
              children: [
                ListTile(
                  leading: Radio<String>(value: 'counter'),
                  title: const Text('Thanh toán trực tiếp tại quầy'),
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

  Widget _summaryCard(num total) {
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
                  widget.attractionTitle,
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatDate(_visitDate)} · $_people người',
                  style: context.captionStyle.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatPrice(widget.basePrice, widget.currencyCode),
                  style: context.bodyOneStyle.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
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
            'Ngày tham quan',
            style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _outlinedChip(
                  icon: LucideIcons.calendar,
                  label: _formatDate(_visitDate),
                  onTap: _openDatePicker,
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
            'Số khách',
            style: context.bodyOneStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _qtyRow(
            label: 'Người',
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
            readOnly: true,
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
        _showSnack('Bạn cần đăng nhập để đặt điểm tham quan.');
        setState(() => _submitting = false);
        return;
      }

      await _updateUserInfoIfNeeded(prefs, uid);

      // COUNTER payment: Create booking immediately
      if (_paymentMethod == 'counter') {
        final api = AttractionBookingApiService(dio: Dio(), prefs: prefs);
        await api.createBooking(
          userId: uid,
          attractionId: widget.attractionId,
          startDate: DateTime(
            _visitDate.year,
            _visitDate.month,
            _visitDate.day,
          ),
          numAdults: _people,
          totalPrice: total,
          currencyCode: (widget.currencyCode ?? 'VND').toUpperCase(),
          providerNotes: _buildProviderNotes(),
          paymentMethod: 'counter',
        );

        // 🔥 Track BOOK action for AI
        try {
          final trackingService = await UserInteractionService.create();
          await trackingService.recordBook(
            itemId: widget.attractionId,
            itemType: 'attraction',
          );
        } catch (e) {
          // Silent fail
        }

        if (!mounted) return;
        setState(() => _submitting = false);
        _showSnack('Đặt chỗ thành công. Thanh toán tại quầy khi đến.');
        Navigator.of(context).pop();
        return;
      }

      // ZALOPAY payment: Do NOT create booking yet, just create order
      try {
        final zalo = ZaloPayApiService(dio: Dio(), prefs: prefs);
        final orderResult = await zalo.createAttractionOrder(
          amount: total,
          userId: uid,
          attractionId: widget.attractionId,
          startDate: DateTime(
            _visitDate.year,
            _visitDate.month,
            _visitDate.day,
          ),
          numAdults: _people,
          providerNotes: _buildProviderNotes(),
          description:
              'Thanh toan dat diem tham quan attraction #${widget.attractionId}',
        );

        final orderUrl = orderResult['order_url']!;
        final appTransId = orderResult['apptransid']!;

        setState(() => _submitting = false);

        if (!mounted) return;
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentWebViewScreen(url: orderUrl),
          ),
        );

        if (result == true) {
          setState(() => _submitting = true);
          try {
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
              final bookingId = (createResponse.data as Map)['bookingId'];

              // 🔥 Track BOOK action for AI
              try {
                final trackingService = await UserInteractionService.create();
                await trackingService.recordBook(
                  itemId: widget.attractionId,
                  itemType: 'attraction',
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
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        const Text('Thanh toán thành công!'),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đặt điểm tham quan của bạn đã được xác nhận.',
                        ),
                        if (bookingId != null)
                          Text(
                            'Mã đặt: #$bookingId',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Bạn có thể kiểm tra chi tiết trong mục "Đơn của tôi".',
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
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                );
              }
            } else {
              _showSnack(
                'Thanh toán thành công nhưng không tạo được đặt chỗ. Vui lòng liên hệ hỗ trợ.',
              );
            }
          } catch (e) {
            setState(() => _submitting = false);
            _showSnack(
              'Thanh toán thành công nhưng lỗi tạo đặt chỗ: ${e.toString()}',
            );
          }
        } else {
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
