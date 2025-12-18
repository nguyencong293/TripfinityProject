class RecommendationItem {
  final String title;
  final String itemType;
  final String priceFmt;
  final double distKm;
  final double score;

  RecommendationItem({
    required this.title,
    required this.itemType,
    required this.priceFmt,
    required this.distKm,
    required this.score,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      title: json['title'] ?? '',
      itemType: json['item_type'] ?? '',
      priceFmt: json['price_fmt'] ?? '',
      distKm: (json['dist_km'] ?? 0).toDouble(),
      score: (json['score'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'item_type': itemType,
      'price_fmt': priceFmt,
      'dist_km': distKm,
      'score': score,
    };
  }
}
