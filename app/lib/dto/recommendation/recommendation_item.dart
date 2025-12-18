import 'package:flutter/foundation.dart';

class RecommendationItem {
  final int itemId;
  final String title;
  final String itemType;
  final String priceFmt;
  final double distKm;
  final double score;

  RecommendationItem({
    required this.itemId,
    required this.title,
    required this.itemType,
    required this.priceFmt,
    required this.distKm,
    required this.score,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    // Debug: print raw JSON
    debugPrint('🔧 Parsing recommendation item: $json');

    // Try multiple possible field names for item_id
    final itemId = json['item_id'] ?? json['itemId'] ?? json['id'] ?? 0;

    // Try multiple possible field names for item_type
    final itemType =
        json['item_type'] ?? json['itemType'] ?? json['type'] ?? '';

    final parsed = RecommendationItem(
      itemId: itemId is int ? itemId : int.tryParse(itemId.toString()) ?? 0,
      title: json['title'] ?? '',
      itemType: itemType.toString(),
      priceFmt: json['price_fmt'] ?? json['priceFmt'] ?? '',
      distKm: (json['dist_km'] ?? json['distKm'] ?? 0).toDouble(),
      score: (json['score'] ?? 0).toDouble(),
    );

    debugPrint(
      '   → Parsed: id=${parsed.itemId}, type="${parsed.itemType}", title="${parsed.title}"',
    );
    return parsed;
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'title': title,
      'item_type': itemType,
      'price_fmt': priceFmt,
      'dist_km': distKm,
      'score': score,
    };
  }
}
