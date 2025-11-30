import 'package:app/services/fcm_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Màn hình debug FCM để test notification
class FCMDebugScreen extends StatefulWidget {
  const FCMDebugScreen({super.key});

  @override
  State<FCMDebugScreen> createState() => _FCMDebugScreenState();
}

class _FCMDebugScreenState extends State<FCMDebugScreen> {
  String? _fcmToken;
  bool _permissionGranted = false;
  final _fcmService = FCMService();

  @override
  void initState() {
    super.initState();
    _loadFCMToken();
  }

  Future<void> _loadFCMToken() async {
    try {
      final token = await _fcmService.getFCMToken();
      setState(() {
        _fcmToken = token;
        _permissionGranted = token != null;
      });
    } catch (e) {
      debugPrint('Error loading FCM token: $e');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('✅ Đã copy FCM token')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐛 FCM Debug'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permission Status
            Card(
              color: _permissionGranted ? Colors.green[50] : Colors.red[50],
              child: ListTile(
                leading: Icon(
                  _permissionGranted ? Icons.check_circle : Icons.error,
                  color: _permissionGranted ? Colors.green : Colors.red,
                ),
                title: Text(
                  _permissionGranted
                      ? '✅ Notification Permission Granted'
                      : '❌ Notification Permission Denied',
                  style: TextStyle(
                    color: _permissionGranted ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _permissionGranted
                      ? 'App có thể nhận push notifications'
                      : 'Vào Settings → Permissions để bật',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // FCM Token
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.vpn_key, color: Colors.deepPurple),
                        const SizedBox(width: 8),
                        const Text(
                          'FCM Token',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_fcmToken != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _fcmToken!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _copyToClipboard(_fcmToken!),
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Token'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        '❌ Không có FCM token',
                        style: TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _loadFCMToken,
                        child: const Text('Refresh Token'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Hướng dẫn test',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep('1', 'Copy FCM token ở trên'),
                    _buildInstructionStep(
                      '2',
                      'Kiểm tra database:\nSELECT fcm_token FROM users WHERE user_id = [YOUR_ID];',
                    ),
                    _buildInstructionStep(
                      '3',
                      'Test từ Firebase Console:\nconsole.firebase.google.com → Cloud Messaging → Send test message',
                    ),
                    _buildInstructionStep('4', 'Hoặc đặt booking để test thật'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Test Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.science, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Test Actions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _fcmService.subscribeToTopic('test-topic');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Subscribed to test-topic'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.add_alert),
                        label: const Text('Subscribe to Test Topic'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          await _fcmService.unsubscribeFromTopic('test-topic');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Unsubscribed from test-topic'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        label: const Text('Unsubscribe from Test Topic'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.blue,
            child: Text(
              number,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
