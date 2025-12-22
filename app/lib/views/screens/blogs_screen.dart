import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/blog_api_service.dart';
import 'package:app/views/screens/blog_detail_screen.dart';

/// Model đơn giản cho Blog
class BlogInfo {
  final int blogId;
  final String title;
  final String slug;
  final String content;
  final String? coverImageUrl;
  final String? tags;
  final int viewsCount;
  final int likesCount;
  final String? publishedAt;
  final String? bloggerName;
  final String? bloggerAvatar;

  BlogInfo({
    required this.blogId,
    required this.title,
    required this.slug,
    required this.content,
    this.coverImageUrl,
    this.tags,
    this.viewsCount = 0,
    this.likesCount = 0,
    this.publishedAt,
    this.bloggerName,
    this.bloggerAvatar,
  });

  factory BlogInfo.fromJson(Map<String, dynamic> json) {
    return BlogInfo(
      blogId: json['blogId'] ?? json['blog_id'] ?? 0,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      content: json['content'] ?? '',
      coverImageUrl: json['coverImageUrl'] ?? json['cover_image_url'],
      tags: json['tags'],
      viewsCount: json['viewsCount'] ?? json['views_count'] ?? 0,
      likesCount: json['likesCount'] ?? json['likes_count'] ?? 0,
      publishedAt: json['publishedAt'] ?? json['published_at'],
      bloggerName: json['bloggerName'] ?? json['blogger_name'],
      bloggerAvatar: json['bloggerAvatar'] ?? json['blogger_avatar'],
    );
  }
}

/// Screen hiển thị danh sách bài viết
class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<BlogInfo> _blogs = [];
  List<BlogInfo> _filteredBlogs = [];
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
    await _loadBlogs();
  }

  Future<void> _loadBlogs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _blogService!.getAllPublishedBlogs();
      final blogs = data.map((json) => BlogInfo.fromJson(json)).toList();

      setState(() {
        _blogs = blogs;
        _filteredBlogs = blogs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading blogs: $e');
      setState(() {
        _error = 'Không thể tải danh sách bài viết';
        _isLoading = false;
      });
    }
  }

  void _filterBlogs(String query) {
    if (query.isEmpty) {
      setState(() => _filteredBlogs = _blogs);
      return;
    }

    final filtered = _blogs.where((blog) {
      final title = blog.title.toLowerCase();
      final content = blog.content.toLowerCase();
      final tags = blog.tags?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return title.contains(searchQuery) ||
          content.contains(searchQuery) ||
          tags.contains(searchQuery);
    }).toList();

    setState(() => _filteredBlogs = filtered);
  }

  void _onSelectBlog(BlogInfo blog) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlogDetailScreen(blogId: blog.blogId),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _stripHtml(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.cardBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: context.textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Khám phá bài viết', style: context.h4Style),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: context.cardBackgroundColor,
            child: TextField(
              controller: _searchController,
              onChanged: _filterBlogs,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài viết...',
                hintStyle: context.bodyOneStyle.copyWith(
                  color: context.textSecondaryColor,
                ),
                prefixIcon: Icon(
                  LucideIcons.search,
                  color: context.textSecondaryColor,
                ),
                filled: true,
                fillColor: context.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
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
              onPressed: _loadBlogs,
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

    if (_filteredBlogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.fileText, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài viết nào',
              style: context.bodyOneStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Các bài viết sẽ xuất hiện ở đây',
              style: context.bodyTwoStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBlogs,
      color: context.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredBlogs.length,
        itemBuilder: (context, index) {
          final blog = _filteredBlogs[index];
          return _buildBlogCard(blog);
        },
      ),
    );
  }

  Widget _buildBlogCard(BlogInfo blog) {
    return GestureDetector(
      onTap: () => _onSelectBlog(blog),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: context.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: blog.coverImageUrl != null
                    ? Image.network(
                        blog.coverImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stackTrace) {
                          return Container(
                            color: ctx.backgroundColor,
                            child: Center(
                              child: Icon(
                                LucideIcons.image,
                                size: 48,
                                color: Colors.grey[300],
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: context.backgroundColor,
                        child: Center(
                          child: Icon(
                            LucideIcons.fileText,
                            size: 48,
                            color: Colors.grey[300],
                          ),
                        ),
                      ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    blog.title,
                    style: context.h5Style,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Preview content
                  Text(
                    _stripHtml(blog.content),
                    style: context.bodyTwoStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Tags
                  if (blog.tags != null && blog.tags!.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: blog.tags!.split(',').take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '#${tag.trim()}',
                            style: context.captionStyle.copyWith(
                              color: context.primaryColor,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 12),

                  // Footer: Author & Stats
                  Row(
                    children: [
                      // Author
                      if (blog.bloggerAvatar != null)
                        CircleAvatar(
                          radius: 12,
                          backgroundImage: NetworkImage(blog.bloggerAvatar!),
                        )
                      else
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: context.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          child: Text(
                            (blog.bloggerName ?? 'A')[0].toUpperCase(),
                            style: context.captionStyle.copyWith(
                              color: context.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              blog.bloggerName ?? 'Anonymous',
                              style: context.captionStyle.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              _formatDate(blog.publishedAt),
                              style: context.captionStyle.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stats
                      Row(
                        children: [
                          Icon(
                            LucideIcons.eye,
                            size: 14,
                            color: context.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${blog.viewsCount}',
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            LucideIcons.heart,
                            size: 14,
                            color: context.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${blog.likesCount}',
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
