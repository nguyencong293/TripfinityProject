import 'package:app/config/theme/app_colors.dart';
import 'package:app/routes/app_router.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> postData;

  const PostDetailScreen({super.key, required this.postData});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late final ScrollController _scrollController;
  bool _showAppBarTitle = false;

  // Demo related posts
  final List<Map<String, dynamic>> _relatedPosts = List.generate(3, (i) {
    return {
      'id': 'related_$i',
      'title': i.isEven
          ? '10 lời khuyên giúp biến đánh giá tiêu cực về nhà hàng thành cơ hội'
          : 'Khám phá các điểm du lịch nổi tiếng ở Đà Nẵng năm 2025',
      'author': 'Nguyễn Thành Công',
      'date': DateTime(2025, 6, 10).toIso8601String(),
      'views': 8000 + i * 240,
      'image': 'assets/images/onboarding${(i % 4) + 1}.png',
    };
  });

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 180 && !_showAppBarTitle) {
      setState(() {
        _showAppBarTitle = true;
      });
    } else if (_scrollController.offset <= 180 && _showAppBarTitle) {
      setState(() {
        _showAppBarTitle = false;
      });
    }
  }

  void _sharePost() {
    final title = widget.postData['title'] as String? ?? '';
    Share.share('$title - Xem thêm trên ứng dụng Tripfinity');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.postData['title'] as String? ?? '';
    final author = widget.postData['author'] as String? ?? '';
    final date =
        DateTime.tryParse(widget.postData['date'] as String? ?? '') ??
        DateTime.now();
    final views = widget.postData['views'] as int? ?? 0;
    final img =
        widget.postData['image'] as String? ?? 'assets/images/onboarding4.png';
    final tags =
        (widget.postData['tags'] as List?)?.cast<String>() ?? <String>[];
    final heroTag = 'post-image-${widget.postData['id'] ?? title}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: _BackButton(color: _showAppBarTitle ? null : Colors.white),
            titleSpacing: 0,
            title: _showAppBarTitle
                ? Padding(
                    padding: const EdgeInsets.only(right: 60.0),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : null,
            actions: [
              _ShareButton(onTap: _sharePost, isCollapsed: _showAppBarTitle),
              const SizedBox(width: 12),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: heroTag,
                    child: Image.asset(img, fit: BoxFit.cover),
                  ),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(179), // ~0.7 opacity
                        ],
                        stops: const [0.6, 1.0],
                      ),
                    ),
                  ),
                  // Post title overlay - không có card
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: tags
                                .take(2)
                                .map((tag) => _TagPill(label: tag))
                                .toList(),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author and date
                  _AuthorInfo(author: author, date: date, views: views),
                  const SizedBox(height: 24),

                  // Post content
                  Text(
                    'Đối với hầu hết thực khách, ấn tượng đầu tiên về nhà hàng đến từ những đánh giá trực tuyến trên các trang web như Tripadvisor và Google...',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: 16),

                  Text(
                    'Dưới đây là một số hành động nên thực hiện:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _BulletPoint(
                    text: 'Phản hồi kịp thời và thể hiện sự tôn trọng.',
                  ),
                  const SizedBox(height: 10),
                  _BulletPoint(
                    text: 'Luôn giữ thái độ chuyên nghiệp và lịch sự.',
                  ),
                  const SizedBox(height: 10),
                  _BulletPoint(
                    text: 'Chủ động liên hệ để giải quyết các vấn đề nếu có.',
                  ),
                  const SizedBox(height: 10),
                  _BulletPoint(
                    text:
                        'Đưa ra giải pháp, ưu đãi nhỏ để cải thiện trải nghiệm.',
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Nhìn chung, biến phản hồi tiêu cực thành cơ hội là cách giúp nâng cao chất lượng dịch vụ và hình ảnh thương hiệu của nhà hàng.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Social sharing
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: Theme.of(context).dividerColor.withAlpha(77),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'share_article'.tr,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: LucideIcons.facebook,
                          color: const Color(0xFF1877F2),
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _SocialButton(
                          icon: LucideIcons.twitter,
                          color: const Color(0xFF1DA1F2),
                          onTap: () {},
                        ),
                        const SizedBox(width: 12),
                        _SocialButton(
                          icon: LucideIcons.linkedin,
                          color: const Color(0xFF0A66C2),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Related posts
                  Text(
                    'related_posts'.tr,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._relatedPosts.map(
                    (post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _RelatedPostItem(
                        data: post,
                        onTap: () =>
                            context.push(AppRouter.postDetail, extra: post),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  final Color? color;

  const _BackButton({this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        LucideIcons.arrowLeft,
        color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
      ),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}

// Widget nút Share với background tròn
class _ShareButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isCollapsed;

  const _ShareButton({required this.onTap, required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4.0),
      decoration: BoxDecoration(
        color: isCollapsed
            ? Colors.transparent
            : Colors.black.withAlpha(
                40,
              ), // Semi-transparent background khi expanded
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          LucideIcons.share2,
          color: isCollapsed
              ? Theme.of(context).textTheme.bodyLarge?.color
              : Colors.white,
        ),
        tooltip: 'share'.tr,
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final String label;

  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  final String author;
  final DateTime date;
  final int views;

  const _AuthorInfo({
    required this.author,
    required this.date,
    required this.views,
  });

  @override
  Widget build(BuildContext context) {
    String ddmmyyyy(DateTime d) => '${d.day}/${d.month}/${d.year}';

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Theme.of(context).dividerColor.withAlpha(77),
          child: Text(
            author.isNotEmpty ? author[0].toUpperCase() : 'U',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                author,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ddmmyyyy(date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    LucideIcons.eye,
                    size: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    views.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(26), // ~0.1 opacity
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

// Card nhỏ hơn cho related posts
class _RelatedPostItem extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _RelatedPostItem({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? '';
    final author = data['author'] as String? ?? '';
    final img = data['image'] as String? ?? 'assets/images/onboarding4.png';

    return Container(
      height: 80, // Giảm chiều cao từ 100 xuống 80
      padding: const EdgeInsets.all(8), // Giảm padding từ 12 xuống 8
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(51)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                img,
                width: 64, // Giảm từ 76 xuống 64
                height: 64, // Giảm từ 76 xuống 64
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10), // Giảm từ 12 xuống 10
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      // Thay đổi từ bodyLarge
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // Giảm từ 8 xuống 4
                  Row(
                    children: [
                      Icon(
                        LucideIcons.user,
                        size: 12, // Giảm từ 14 xuống 12
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4), // Giảm từ 6 xuống 4
                      Expanded(
                        child: Text(
                          author,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 28, // Giảm từ 32 xuống 28
              height: 28, // Giảm từ 32 xuống 28
              decoration: BoxDecoration(
                color: context.cardBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.chevronRight,
                size: 16, // Giảm từ 18 xuống 16
                color: context.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
