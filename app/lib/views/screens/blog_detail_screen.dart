import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/blog_api_service.dart';

/// Screen hiển thị chi tiết bài viết
class BlogDetailScreen extends StatefulWidget {
  final int blogId;

  const BlogDetailScreen({super.key, required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  Map<String, dynamic>? _blog;
  bool _isLoading = true;
  String? _error;
  BlogApiService? _blogService;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();
    _blogService = BlogApiService(dio: dio, prefs: prefs);
    await _loadBlog();
  }

  Future<void> _loadBlog() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _blogService!.getBlogById(widget.blogId);
      setState(() {
        _blog = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading blog: $e');
      setState(() {
        _error = 'Không thể tải bài viết';
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Tháng 1',
        'Tháng 2',
        'Tháng 3',
        'Tháng 4',
        'Tháng 5',
        'Tháng 6',
        'Tháng 7',
        'Tháng 8',
        'Tháng 9',
        'Tháng 10',
        'Tháng 11',
        'Tháng 12',
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardBackgroundColor,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: context.primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: context.bodyOneStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBlog,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_blog == null) {
      return const Center(child: Text('Không tìm thấy bài viết'));
    }

    final coverImageUrl = _blog!['coverImageUrl'] ?? _blog!['cover_image_url'];
    final title = _blog!['title'] ?? '';
    final content = _blog!['content'] ?? '';
    final tags = _blog!['tags'] as String?;
    final viewsCount = _blog!['viewsCount'] ?? _blog!['views_count'] ?? 0;
    final likesCount = _blog!['likesCount'] ?? _blog!['likes_count'] ?? 0;
    final publishedAt = _blog!['publishedAt'] ?? _blog!['published_at'];
    final bloggerName =
        _blog!['bloggerName'] ?? _blog!['blogger_name'] ?? 'Anonymous';
    final bloggerAvatar = _blog!['bloggerAvatar'] ?? _blog!['blogger_avatar'];

    return CustomScrollView(
      slivers: [
        // App Bar with Cover Image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          backgroundColor: context.cardBackgroundColor,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.cardBackgroundColor.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                LucideIcons.arrowLeft,
                color: context.textPrimaryColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: coverImageUrl != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        coverImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stackTrace) {
                          return Container(
                            color: ctx.backgroundColor,
                            child: Center(
                              child: Icon(
                                LucideIcons.image,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                            ),
                          );
                        },
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    color: context.backgroundColor,
                    child: Center(
                      child: Icon(
                        LucideIcons.fileText,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(title, style: context.h2Style.copyWith(height: 1.3)),
                const SizedBox(height: 16),

                // Author Info & Stats
                Row(
                  children: [
                    // Author avatar
                    if (bloggerAvatar != null)
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(bloggerAvatar),
                      )
                    else
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: context.primaryColor.withValues(
                          alpha: 0.2,
                        ),
                        child: Text(
                          bloggerName[0].toUpperCase(),
                          style: context.bodyOneStyle.copyWith(
                            color: context.primaryColor,
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
                            bloggerName,
                            style: context.bodyOneStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatDate(publishedAt),
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Stats
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: context.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.eye,
                            size: 16,
                            color: context.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$viewsCount',
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            LucideIcons.heart,
                            size: 16,
                            color: context.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$likesCount',
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Tags
                if (tags != null && tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.split(',').map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#${tag.trim()}',
                          style: context.bodyTwoStyle.copyWith(
                            color: context.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Divider
                Container(height: 1, color: context.backgroundColor),
                const SizedBox(height: 24),

                // Content
                Text(
                  content,
                  style: context.bodyOneStyle.copyWith(height: 1.8),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
