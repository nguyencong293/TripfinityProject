import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  const PaymentWebViewScreen({super.key, required this.url});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController? _controller;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Web platform: ZaloPay không hỗ trợ Web
    if (kIsWeb) {
      _controller = null;
      setState(() {
        _loading = false;
      });
    } else {
      // Mobile: Dùng WebView như bình thường
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              if (mounted) {
                setState(() => _loading = false);

                // Auto-close WebView when payment is successful
                // ZaloPay shows success page with these URL patterns
                if (url.contains('success') ||
                    url.contains('payment-success') ||
                    url.contains('status=1') ||
                    url.contains('return_code=1')) {
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      Navigator.of(context).pop(true);
                    }
                  });
                }
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              // Auto-close on success URLs
              if (request.url.contains('success') ||
                  request.url.contains('payment-success') ||
                  request.url.contains('status=1') ||
                  request.url.contains('return_code=1')) {
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    Navigator.of(context).pop(true);
                  }
                });
              }

              // Allow ALL URLs to navigate - WebView will show payment options
              return NavigationDecision.navigate;
            },
            onWebResourceError: (error) {
              // Ignore unsupported scheme errors (zalopay://, intent://)
              if (error.errorType != WebResourceErrorType.unsupportedScheme &&
                  error.isForMainFrame == true) {
                if (mounted) {
                  setState(() {
                    _errorMessage = 'Lỗi tải trang thanh toán';
                    _loading = false;
                  });
                }
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  // Widget helper để hiển thị bước hướng dẫn
  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Web platform: ZaloPay KHÔNG hỗ trợ - hiển thị thông báo
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thanh toán'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon cảnh báo
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      size: 80,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tiêu đề
                  const Text(
                    'Thanh toán ZaloPay không khả dụng trên Web',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Thông báo chính
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ZaloPay Sandbox chỉ hỗ trợ mobile app',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ZaloPay yêu cầu native mobile app (Android/iOS) để xử lý thanh toán. '
                          'Nền tảng Web không được hỗ trợ trong môi trường Sandbox.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade900,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Hướng dẫn
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Giải pháp',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInstructionStep(
                          '1',
                          'Sử dụng ứng dụng mobile (Android/iOS)',
                        ),
                        _buildInstructionStep(
                          '2',
                          'Hoặc chọn phương thức thanh toán khác',
                        ),
                        _buildInstructionStep(
                          '3',
                          'Hoặc liên hệ admin để được hỗ trợ',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Chi tiết kỹ thuật (nếu cần debug)
                  ExpansionTile(
                    title: const Text(
                      'Chi tiết kỹ thuật',
                      style: TextStyle(fontSize: 14),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lỗi từ ZaloPay SDK:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '• Unsupported pmcId: 44\n'
                                '• orderInfo is not valid\n'
                                '• Run in ZaloPayClient please!\n'
                                '• checkOrderPaymentSupport failed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Platform: Web Browser\n'
                              'ZaloPay SDK: Sandbox mode\n'
                              'Hỗ trợ: Android & iOS only',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Nút đóng
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close),
                      label: const Text('Đóng', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.grey.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Mobile platform: Dùng WebView như bình thường
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán ZaloPay'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Show confirmation dialog before closing
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Hủy thanh toán?'),
                content: const Text(
                  'Bạn có chắc muốn hủy giao dịch? Đặt phòng sẽ không được xác nhận.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Tiếp tục thanh toán'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(
                        false,
                      ); // Close WebView with FALSE - payment cancelled
                    },
                    child: const Text(
                      'Hủy',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        // REMOVED "Hoàn tất" button - SECURITY FIX
        // Users were able to click "Complete" without actually paying
        // Only auto-close on success URL detection is allowed
      ),
      body: Stack(
        children: [
          if (_errorMessage == null && _controller != null)
            WebViewWidget(controller: _controller)
          else if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Đóng'),
                    ),
                  ],
                ),
              ),
            ),
          if (_loading && _errorMessage == null)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
