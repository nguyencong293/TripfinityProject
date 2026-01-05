import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;

/// Model cho service item từ chatbot
class ChatServiceItem {
  final int itemId;
  final String itemType;
  final String title;
  final String location;
  final double price;
  final double starRating;

  ChatServiceItem({
    required this.itemId,
    required this.itemType,
    required this.title,
    required this.location,
    required this.price,
    required this.starRating,
  });

  factory ChatServiceItem.fromJson(Map<String, dynamic> json) {
    return ChatServiceItem(
      itemId: json['item_id'] ?? 0,
      itemType: json['item_type'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      starRating: (json['star_rating'] ?? 0).toDouble(),
    );
  }

  /// Format giá tiền theo VND
  String get formattedPrice {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M đ';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K đ';
    }
    return '${price.toStringAsFixed(0)} đ';
  }
}

class TripBotService {
  static const String _baseUrl = 'https://db9373f3d797.ngrok-free.app ';
  static const String _chatEndpoint = '/api/chat';
  static const Duration _timeout = Duration(seconds: 30);

  static Future<TripBotResponse> sendMessage(String message) async {
    try {
      debugPrint('🚀 Sending message: $message'); // Debug log

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

      debugPrint('📡 Response status: ${response.statusCode}'); // Debug log
      debugPrint('📡 Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // Parse items từ response
        List<ChatServiceItem> items = [];
        if (data['items'] != null && data['items'] is List) {
          items = (data['items'] as List)
              .map((item) => ChatServiceItem.fromJson(item))
              .toList();
        }

        return TripBotResponse.success(
          data['response'] ?? 'Xin lỗi, tôi không thể trả lời câu hỏi này.',
          items: items,
        );
      } else {
        return TripBotResponse.error(
          'Server error: ${response.statusCode}',
          TripBotErrorType.serverError,
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('❌ Client error: $e'); // Debug log
      return TripBotResponse.error(
        'Không thể kết nối đến server: ${e.message}',
        TripBotErrorType.networkError,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ General error: $e'); // Debug log
      debugPrint('❌ Stack trace: $stackTrace'); // Debug stack trace
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
  final List<ChatServiceItem> items;

  const TripBotResponse._({
    required this.isSuccess,
    required this.message,
    this.errorType,
    this.items = const [],
  });

  factory TripBotResponse.success(
    String message, {
    List<ChatServiceItem>? items,
  }) {
    return TripBotResponse._(
      isSuccess: true,
      message: message,
      items: items ?? [],
    );
  }

  factory TripBotResponse.error(String message, TripBotErrorType errorType) {
    return TripBotResponse._(
      isSuccess: false,
      message: message,
      errorType: errorType,
    );
  }

  bool get hasItems => items.isNotEmpty;

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
