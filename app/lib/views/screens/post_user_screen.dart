import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/routes/app_router.dart';
import 'package:app/services/localization_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PostUserScreen extends StatefulWidget {
  const PostUserScreen({super.key});

  @override
  State<PostUserScreen> createState() => _PostUserScreenState();
}

class _PostUserScreenState extends State<PostUserScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _selectedTags = {'Đà Nẵng', 'Mới nhất'};
  bool _isSearchFocused = false;

  // Demo dataset
  final List<Map<String, dynamic>> _allPosts = List.generate(6, (i) {
    return {
      'id': 'p$i',
      'title':
          '10 lời khuyên giúp biến đánh giá tiêu cực về nhà hàng thành cơ hội',
      'author': 'Nguyễn Thành Công',
      'date': DateTime(2025, 6, 12).toIso8601String(),
      'views': 10000 + i * 120,
      'tags': ['Mới nhất', 'Đà Nẵng'],
      'image': 'assets/images/onboarding${(i % 4) + 1}.png',
      'summary':
          'Đối với hầu hết thực khách, ấn tượng đầu tiên về nhà hàng đến từ những đánh giá trực tuyến trên các trang web như Tripadvisor và Google...',
    };
  });

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _allPosts.where((p) {
      final matchQuery =
          q.isEmpty || (p['title'] as String).toLowerCase().contains(q);
      final tags = (p['tags'] as List).cast<String>().toSet();
      final matchTags =
          _selectedTags.isEmpty || _selectedTags.every(tags.contains);
      return matchQuery && matchTags;
    }).toList();
  }

  void _openFilter() async {
    final options = <String>{
      'Đà Nẵng',
      'Hà Nội',
      'Hồ Chí Minh',
      'Mới nhất',
      'Nổi bật',
      'Ẩm thực',
      'Du lịch',
      'Khách sạn',
    };
    final temp = {..._selectedTags};

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: StatefulBuilder(
              builder: (ctx, setLocalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Icon(
                          LucideIcons.slidersHorizontal,
                          color: context.primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'filter'.tr,
                          style: context.h5Style.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: options.map((t) {
                        final selected = temp.contains(t);
                        return FilterChip(
                          selected: selected,
                          selectedColor: context.primaryColor.withValues(
                            alpha: 0.15,
                          ),
                          backgroundColor: context.backgroundColor,
                          checkmarkColor: context.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: selected
                                  ? context.primaryColor
                                  : context.dividerColor,
                              width: 1,
                            ),
                          ),
                          label: Text(
                            t,
                            style: context.bodyTwoStyle.copyWith(
                              color: selected
                                  ? context.primaryColor
                                  : context.textPrimaryColor,
                            ),
                          ),
                          onSelected: (v) {
                            setLocalState(() {
                              if (v) {
                                temp.add(t);
                              } else {
                                temp.remove(t);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('cancel'.tr),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedTags
                                  ..clear()
                                  ..addAll(temp);
                              });
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text('apply'.tr),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = _filtered.isEmpty;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.x, color: context.textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'posts_title'.tr,
          style: context.h5Style.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header with search and filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _SearchBar(
                      controller: _searchCtrl,
                      hint: 'posts_search_hint'.tr,
                      onChanged: (_) => setState(() {}),
                      onFocusChange: (focused) => setState(() {
                        _isSearchFocused = focused;
                      }),
                      isFocused: _isSearchFocused,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _FilterButton(
                    onTap: _openFilter,
                    label: 'filter'.tr,
                    badgeCount: _selectedTags.length,
                  ),
                ],
              ),
            ),

            // Selected tags
            if (_selectedTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _selectedTags.map((t) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _TagChip(
                          label: t,
                          onRemove: () => setState(() {
                            _selectedTags.remove(t);
                          }),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Section title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'top_latest_posts'.tr,
                    style: context.h5Style.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isEmpty)
                    Text(
                      '${_filtered.length} ${'articles'.tr}',
                      style: context.captionStyle.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                ],
              ),
            ),

            // List of posts
            Expanded(
              child: isEmpty
                  ? _EmptyState(
                      message: 'no_posts_found'.tr,
                      onClearFilter: _selectedTags.isNotEmpty
                          ? () => setState(() => _selectedTags.clear())
                          : null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 20),
                      itemBuilder: (ctx, index) {
                        final p = _filtered[index];
                        return _PostCard(
                          data: p,
                          onReadMore: () =>
                              context.push(AppRouter.postDetail, extra: p),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onClearFilter;

  const _EmptyState({required this.message, this.onClearFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.fileSearch,
            size: 64,
            color: context.textSecondaryColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: context.bodyTwoStyle.copyWith(
              color: context.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (onClearFilter != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onClearFilter,
              icon: const Icon(LucideIcons.filterX),
              label: Text('clear_filters'.tr),
            ),
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<bool> onFocusChange;
  final bool isFocused;

  const _SearchBar({
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onFocusChange,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: context.bodyOneStyle,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: context.bodyOneStyle.copyWith(
                color: context.textSecondaryColor.withValues(alpha: 0.7),
              ),
              prefixIcon: Icon(
                LucideIcons.search,
                color: context.textPrimaryColor,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              filled: true,
              // dùng token từ theme
              fillColor: context.cardBackgroundColor.withValues(alpha: 0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (controller.text.isNotEmpty)
          IconButton(
            onPressed: () {
              controller.clear();
              onChanged('');
            },
            icon: const Icon(LucideIcons.x, size: 18),
            splashRadius: 20,
            color: context.textSecondaryColor,
          ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final int badgeCount;

  const _FilterButton({
    required this.onTap,
    required this.label,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: badgeCount > 0
                    ? context.primaryColor.withValues(alpha: 0.5)
                    : context.dividerColor.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.slidersHorizontal,
                  size: 18,
                  color: badgeCount > 0
                      ? context.primaryColor
                      : context.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: context.bodyTwoStyle.copyWith(
                    color: badgeCount > 0
                        ? context.primaryColor
                        : context.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _TagChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: context.captionStyle.copyWith(
              color: context.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(LucideIcons.x, size: 12, color: context.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onReadMore;
  const _PostCard({required this.data, required this.onReadMore});

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? '';
    final author = data['author'] as String? ?? '';
    final date =
        DateTime.tryParse(data['date'] as String? ?? '') ?? DateTime.now();
    final views = data['views'] as int? ?? 0;
    final img = data['image'] as String? ?? 'assets/images/onboarding4.png';
    final summary = data['summary'] as String? ?? '';
    final heroTag = 'post-image-${data['id'] ?? title}';
    final tags = (data['tags'] as List?)?.cast<String>() ?? <String>[];

    return Material(
      color: context.cardBackgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onReadMore,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Hero(
                      tag: heroTag,
                      child: Image.asset(
                        img,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (tags.isNotEmpty)
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Wrap(
                        spacing: 8,
                        children: tags
                            .take(2)
                            .map((tag) => _PostTagPill(label: tag))
                            .toList(),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.h5Style.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      summary,
                      style: context.bodyTwoStyle.copyWith(
                        color: context.textSecondaryColor,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    _Meta(author: author, date: date, views: views),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: onReadMore,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('read_more'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostTagPill extends StatelessWidget {
  final String label;

  const _PostTagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: context.captionStyle.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final String author;
  final DateTime date;
  final int views;
  const _Meta({required this.author, required this.date, required this.views});

  @override
  Widget build(BuildContext context) {
    final textStyle = context.captionStyle.copyWith(
      color: context.textSecondaryColor,
    );
    String ddmmyyyy(DateTime d) => '${d.day}/${d.month}/${d.year}';

    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: context.dividerColor.withValues(alpha: 0.3),
          child: Text(
            author.isNotEmpty ? author[0].toUpperCase() : 'U',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            author,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16),
        Icon(LucideIcons.calendar, size: 14, color: context.textSecondaryColor),
        const SizedBox(width: 4),
        Text(ddmmyyyy(date), style: textStyle),
        const SizedBox(width: 16),
        Icon(LucideIcons.eye, size: 14, color: context.textSecondaryColor),
        const SizedBox(width: 4),
        Text(views.toString(), style: textStyle),
      ],
    );
  }
}
