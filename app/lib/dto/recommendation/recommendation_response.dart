import 'recommendation_item.dart';

class RecommendationResponse {
  final bool success;
  final String message;
  final String? status;
  final String? description;
  final List<RecommendationItem>? data;

  RecommendationResponse({
    required this.success,
    required this.message,
    this.status,
    this.description,
    this.data,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'],
      description: json['description'],
      data: json['data'] != null
          ? (json['data'] as List)
                .map((item) => RecommendationItem.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'description': description,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}
