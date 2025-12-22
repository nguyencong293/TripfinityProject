import 'package:app/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/services/attraction_api_service.dart';
import 'package:app/services/review_api_service.dart';

class AttractionReviewsListScreen extends StatefulWidget {
  final int attractionId;
  final String attractionName;

  const AttractionReviewsListScreen({
    super.key,
    required this.attractionId,
    required this.attractionName,
  });

  @override
  State<AttractionReviewsListScreen> createState() =>
      _AttractionReviewsListScreenState();
}

class _AttractionReviewsListScreenState
    extends State<AttractionReviewsListScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  int? _currentUserId;
  final Set<int> _expandedReviews = {};
  final Map<int, List<Map<String, dynamic>>> _repliesCache = {};

  late AttractionApiService _attractionApi;
  late ReviewApiService _reviewApi;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();

    _attractionApi = AttractionApiService(dio: dio, prefs: prefs);
    _reviewApi = ReviewApiService(dio: dio, prefs: prefs);

    // Get current user ID
    _currentUserId = prefs.getInt('user_id');

    await _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      setState(() => _isLoading = true);
      final reviews = await _attractionApi.getAttractionReviews(
        widget.attractionId,
      );

      // Sort by createdAt DESC (newest first)
      reviews.sort((a, b) {
        final aDate = a['createdAt'] as String? ?? '';
        final bDate = b['createdAt'] as String? ?? '';
        return bDate.compareTo(aDate);
      });

      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading reviews: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _loadReplies(int reviewId) async {
    if (_repliesCache.containsKey(reviewId)) {
      return _repliesCache[reviewId]!;
    }

    try {
      final replies = await _reviewApi.getReviewReplies(
        reviewType: 'attraction',
        reviewId: reviewId,
        currentUserId: _currentUserId,
      );

      // Sort replies DESC (newest first)
      replies.sort((a, b) {
        final aDate = a['createdAt'] as String? ?? '';
        final bDate = b['createdAt'] as String? ?? '';
        return bDate.compareTo(aDate);
      });

      _repliesCache[reviewId] = replies;
      return replies;
    } catch (e) {
      debugPrint('Error loading replies: $e');
      return [];
    }
  }

  Future<void> _handleLike(int reviewId, int currentLikes) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để thích đánh giá')),
      );
      return;
    }

    try {
      final result = await _reviewApi.toggleReviewLike(
        userId: _currentUserId!,
        reviewType: 'attraction',
        reviewId: reviewId,
      );

      // Update UI
      setState(() {
        final index = _reviews.indexWhere((r) => r['reviewId'] == reviewId);
        if (index != -1) {
          _reviews[index]['likesCount'] = result['likeCount'];
        }
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['isLiked'] == true ? 'Đã thích đánh giá' : 'Đã bỏ thích',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      debugPrint('Error toggling like: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra. Vui lòng thử lại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tất cả đánh giá',
          style: TextStyle(color: context.textPrimaryColor),
        ),
        backgroundColor: context.backgroundColor,
        iconTheme: IconThemeData(color: context.textPrimaryColor),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 64,
                    color: context.textPrimaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có đánh giá nào',
                    style: TextStyle(
                      fontSize: 16,
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadReviews,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _reviews.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  return _buildReviewCard(review);
                },
              ),
            ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rating = (review['rating'] as num?)?.toInt() ?? 0;
    final userName = review['userName'] as String? ?? 'Khách hàng';
    final title = review['title'] as String?;
    final content = review['content'] as String? ?? '';
    final likesCount = (review['likesCount'] as num?)?.toInt() ?? 0;
    final replyCount = (review['replyCount'] as num?)?.toInt() ?? 0;
    final reviewId = (review['reviewId'] as num?)?.toInt() ?? 0;

    // Parse imageUrls
    final imageUrls = <String>[];
    if (review['imageUrls'] is List) {
      imageUrls.addAll((review['imageUrls'] as List).cast<String>());
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info & rating
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    userName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (title != null && title.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            // Images
            if (imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length > 4 ? 4 : imageUrls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    if (i == 3 && imageUrls.length > 4) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrls[i],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey[300]),
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black54,
                            ),
                            child: Center(
                              child: Text(
                                '+${imageUrls.length - 3}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrls[i],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[300]),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(),
            // Like & Reply buttons
            Row(
              children: [
                InkWell(
                  onTap: () => _handleLike(reviewId, likesCount),
                  child: Row(
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$likesCount Thích',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: () {
                    setState(() {
                      if (_expandedReviews.contains(reviewId)) {
                        _expandedReviews.remove(reviewId);
                      } else {
                        _expandedReviews.add(reviewId);
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$replyCount phản hồi',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Replies section
            if (_expandedReviews.contains(reviewId) && replyCount > 0) ...[
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _loadReplies(reviewId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: snapshot.data!
                        .map((reply) => _buildReplyItem(reply))
                        .toList(),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyItem(Map<String, dynamic> reply) {
    final replierName = reply['replierName']?.toString() ?? 'Người trả lời';
    final content = reply['content']?.toString() ?? '';
    final isProvider = reply['isProvider'] == 1;
    final createdAt = reply['createdAt']?.toString() ?? '';

    // Format date
    String formattedDate = '';
    if (createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);
        formattedDate = '${date.day}/${date.month}/${date.year}';
      } catch (e) {
        formattedDate = '';
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 12, left: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isProvider ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isProvider ? Colors.green : Colors.grey[400]!,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isProvider ? Colors.green : Colors.grey[400],
                child: Icon(
                  isProvider ? Icons.business : Icons.person,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          replierName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isProvider
                                ? Colors.green[800]
                                : Colors.grey[800],
                          ),
                        ),
                        if (isProvider) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Nhà cung cấp',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
