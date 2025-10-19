import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  const PaymentWebViewScreen({super.key, required this.url});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
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
          if (_errorMessage == null)
            WebViewWidget(controller: _controller)
          else
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
