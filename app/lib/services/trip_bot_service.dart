import 'dart:convert';
import 'package:http/http.dart' as http;

class TripBotService {
  static const String _baseUrl = 'https://61adf89b1d31.ngrok-free.app';
  static const String _chatEndpoint = '/api/chat';
  static const Duration _timeout = Duration(seconds: 30);

  static Future<TripBotResponse> sendMessage(String message) async {
    try {
      // print('🚀 Sending message: $message'); // Debug log

      final response = await http
          .post(
            Uri.parse('$_baseUrl$_chatEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
            body: jsonEncode({'message': message}),
          )
          .timeout(_timeout);

      // print('📡 Response status: ${response.statusCode}'); // Debug log
      // print('📡 Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return TripBotResponse.success(
          data['response'] ?? 'Xin lỗi, tôi không thể trả lời câu hỏi này.',
        );
      } else {
        return TripBotResponse.error(
          'Server error: ${response.statusCode}',
          TripBotErrorType.serverError,
        );
      }
    } on http.ClientException catch (e) {
      // print('❌ Client error: $e'); // Debug log
      return TripBotResponse.error(
        'Không thể kết nối đến server: ${e.message}',
        TripBotErrorType.networkError,
      );
    } catch (e) {
      // print('❌ General error: $e'); // Debug log
      return TripBotResponse.error(
        'Đã xảy ra lỗi không xác định: $e',
        TripBotErrorType.unknownError,
      );
    }
  }

  static Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/'),
            headers: {'ngrok-skip-browser-warning': 'true'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

enum TripBotErrorType { networkError, serverError, timeoutError, unknownError }

class TripBotResponse {
  final bool isSuccess;
  final String message;
  final TripBotErrorType? errorType;

  const TripBotResponse._({
    required this.isSuccess,
    required this.message,
    this.errorType,
  });

  factory TripBotResponse.success(String message) {
    return TripBotResponse._(isSuccess: true, message: message);
  }

  factory TripBotResponse.error(String message, TripBotErrorType errorType) {
    return TripBotResponse._(
      isSuccess: false,
      message: message,
      errorType: errorType,
    );
  }

  String get userFriendlyErrorMessage {
    if (isSuccess) return message;

    switch (errorType) {
      case TripBotErrorType.networkError:
        return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      case TripBotErrorType.serverError:
        return 'Server đang gặp sự cố. Vui lòng thử lại sau.';
      case TripBotErrorType.timeoutError:
        return 'Kết nối bị timeout. Vui lòng thử lại.';
      case TripBotErrorType.unknownError:
      default:
        return 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
    }
  }
}
