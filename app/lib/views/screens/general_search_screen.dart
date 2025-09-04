import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Theme & i18n
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/localization_service.dart';

// Import SearchOverviewScreen
import 'search_overview_screen.dart';

class GeneralSearchScreen extends StatefulWidget {
  const GeneralSearchScreen({super.key});

  @override
  State<GeneralSearchScreen> createState() => _GeneralSearchScreenState();
}

class _GeneralSearchScreenState extends State<GeneralSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.text = "Nha Trang";
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: _buildBody(context),
    );
  }

  // Tạo nội dung chính của màn hình
  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        // Phần search bar ở phía trên
        _buildSearchBar(context),

        // Phần nội dung có thể cuộn
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Phần bộ lọc nhanh
                _buildQuickFilters(context),

                const SizedBox(height: 20),

                // Phần kết quả tìm kiếm
                _buildSearchResults(context),

                const SizedBox(height: 32),

                // Phần "Có thể bạn quan tâm"
                _buildSuggestedPlaces(context),

                const SizedBox(height: 32),

                // Phần tìm kiếm gần đây
                _buildNearbySection(context),

                const SizedBox(height: 32),

                // Phần đã xem gần đây
                _buildRecentSection(context),

                // Thêm padding ở cuối để scroll thấy hết nội dung
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Tạo ô tìm kiếm
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(left: 16, top: 30, right: 16, bottom: 20),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'search_hint'.tr,
          hintStyle: context.bodyOneStyle.copyWith(
            color: context.textSecondaryColor,
          ),
          prefixIcon: Icon(
            LucideIcons.search,
            color: context.textSecondaryColor,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    LucideIcons.x,
                    color: context.textSecondaryColor,
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: context.cardBackgroundColor.withValues(alpha: 0.6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(22)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: context.textDisabledColor,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(color: context.primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        style: context.bodyOneStyle,
        onChanged: (value) => setState(() {}),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) {
          _performSearch(value);
        },
      ),
    );
  }

  // Tạo các nút bộ lọc nhanh
  Widget _buildQuickFilters(BuildContext context) {
    final filters = [
      {'label': 'Tất cả', 'icon': LucideIcons.layoutPanelTop, 'selected': true},
      {'label': 'Nhà hàng', 'icon': LucideIcons.utensils, 'selected': false},
      {'label': 'Khách sạn', 'icon': LucideIcons.hotel, 'selected': false},
      {'label': 'Tour du lịch', 'icon': LucideIcons.bus, 'selected': false},
      {
        'label': 'Điểm tham quan',
        'icon': LucideIcons.ticket,
        'selected': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bộ lọc',
          style: context.subTitleOneStyle.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filters
              .map((filter) => _buildFilterChip(context, filter))
              .toList(),
        ),
      ],
    );
  }

  // Tạo từng chip bộ lọc
  Widget _buildFilterChip(BuildContext context, Map<String, dynamic> filter) {
    final isSelected = filter['selected'] as bool;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            filter['icon'] as IconData,
            size: 16,
            color: isSelected
                ? context.buttonTextColor
                : context.textSecondaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            filter['label'] as String,
            style: context.bodyTwoStyle.copyWith(
              color: isSelected
                  ? context.buttonTextColor
                  : context.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      backgroundColor: context.cardBackgroundColor,
      selectedColor: context.primaryColor,
      side: BorderSide(
        color: isSelected ? context.primaryColor : context.dividerColor,
      ),
      onSelected: (selected) {
        // Xử lý khi chọn bộ lọc
      },
    );
  }

  // Phần kết quả tìm kiếm
  Widget _buildSearchResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Danh sách kết quả
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, index) {
            final items = [
              {
                'name': 'Nha Trang',
                'location': 'Việt Nam, Châu Á',
                'rating': '4.1',
                'type': 'destination', // Địa điểm chung
              },
              {
                'name': 'Nha Trang Xưa',
                'location': 'Nha Trang, Việt Nam',
                'rating': '4.2',
                'type': 'restaurant', // Nhà hàng cụ thể
              },
              {
                'name': 'White Rose Restaurant',
                'location': 'Nha Trang, Việt Nam',
                'rating': '4.3',
                'type': 'restaurant', // Nhà hàng cụ thể
              },
              {
                'name': 'Vinpearl - Resort Nha Trang',
                'location': 'Nha Trang, Việt Nam',
                'rating': '4.2',
                'type': 'hotel', // Khách sạn cụ thể
              },
            ];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  final item = items[index];
                  if (item['type'] == 'destination') {
                    // Địa điểm chung → Trang tổng quan
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SearchOverviewScreen(searchQuery: item['name']!),
                      ),
                    );
                  } else {
                    // Item cụ thể → Trang category hoặc detail
                    _navigateToSpecificPage(item['name']!, item['type']!);
                  }
                },
                child: Row(
                  children: [
                    // Hình ảnh
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/onboarding${(index % 4) + 1}.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: context.primaryColor.withValues(alpha: 0.1),
                            child: Icon(
                              LucideIcons.image,
                              color: context.primaryColor,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Thông tin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[index]['name']!,
                            style: context.bodyOneStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[index]['location']!,
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: context.primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                items[index]['rating']!,
                                style: context.captionStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Mũi tên phải
                    Icon(
                      LucideIcons.chevronRight,
                      color: context.textSecondaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        // Nút xem thêm
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Logic thông minh cho "Xem thêm"
              if (_isGeneralSearch(_searchController.text.trim())) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SearchOverviewScreen(
                      searchQuery: _searchController.text.trim(),
                    ),
                  ),
                );
              } else {
                final category = _getSearchCategory(
                  _searchController.text.trim(),
                );
                _navigateToSpecificPage(
                  _searchController.text.trim(),
                  category,
                );
              }
            },
            child: Text(
              'Xem thêm',
              style: context.captionStyle.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // PHẦN MỚI: "Có thể bạn quan tâm"
  Widget _buildSuggestedPlaces(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Có thể bạn quan tâm',
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'Xem thêm',
                style: context.captionStyle.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Danh sách địa điểm gợi ý
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            final suggestions = [
              {
                'name': 'Bãi biển Đồ Sơn',
                'location': 'Hải Phòng, Việt Nam',
                'rating': '4.5',
              },
              {
                'name': 'Thủy cung Times City',
                'location': 'Hà Nội, Việt Nam',
                'rating': '4.7',
              },
              {
                'name': 'Vịnh Hạ Long',
                'location': 'Quảng Ninh, Việt Nam',
                'rating': '4.9',
              },
            ];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  // Điều hướng đến trang tổng quan với địa điểm gợi ý
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SearchOverviewScreen(
                        searchQuery: suggestions[index]['name']!,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    // Hình ảnh
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/onboarding${(index % 3) + 2}.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: context.primaryColor.withValues(alpha: 0.1),
                            child: Icon(
                              LucideIcons.image,
                              color: context.primaryColor,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Thông tin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestions[index]['name']!,
                            style: context.bodyOneStyle.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            suggestions[index]['location']!,
                            style: context.captionStyle.copyWith(
                              color: context.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: context.primaryColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                suggestions[index]['rating']!,
                                style: context.captionStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Mũi tên phải
                    Icon(
                      LucideIcons.chevronRight,
                      color: context.textSecondaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Tạo phần tìm kiếm gần đây
  Widget _buildNearbySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.navigation, color: context.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Gần đây',
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: InkWell(
            onTap: () {
              // Có thể thêm chức năng tìm kiếm theo vị trí
            },
            child: Row(
              children: [
                Icon(LucideIcons.mapPin, color: context.primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tìm kiếm xung quanh',
                        style: context.bodyOneStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Khám phá địa điểm gần vị trí của bạn',
                        style: context.captionStyle.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: context.textSecondaryColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Tạo phần đã xem gần đây
  Widget _buildRecentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Đã xem gần đây',
              style: context.subTitleOneStyle.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                // Xử lý khi nhấn "Xem thêm"
              },
              child: Text(
                'Xem thêm',
                style: context.captionStyle.copyWith(
                  color: context.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3, // Giảm số lượng để không quá dài
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _buildRecentItemTile(context, index);
          },
        ),
      ],
    );
  }

  // Tạo từng item trong danh sách đã xem
  Widget _buildRecentItemTile(BuildContext context, int index) {
    final items = [
      {
        'name': 'White Rose Restaurant',
        'location': 'Nha Trang, Việt Nam',
        'rating': '4.1',
        'type': 'restaurant',
      },
      {
        'name': 'Vinpearl - Resort Nha Trang',
        'location': 'Nha Trang, Việt Nam',
        'rating': '4.2',
        'type': 'hotel',
      },
      {
        'name': 'Thấp Chăm Po Nagar',
        'location': 'Nha Trang, Việt Nam',
        'rating': '4.3',
        'type': 'activity',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: () {
          final item = items[index];
          // Điều hướng thông minh dựa trên type
          _navigateToSpecificPage(item['name']!, item['type']!);
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/onboarding${(index % 4) + 1}.png',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: context.primaryColor.withValues(alpha: 0.1),
                    child: Icon(
                      LucideIcons.image,
                      color: context.primaryColor,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[index]['name']!,
                    style: context.bodyOneStyle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[index]['location']!,
                    style: context.captionStyle.copyWith(
                      color: context.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: context.primaryColor,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        items[index]['rating']!,
                        style: context.captionStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              color: context.textSecondaryColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // Hàm kiểm tra loại tìm kiếm
  bool _isGeneralSearch(String query) {
    final generalKeywords = [
      'nha trang',
      'đà nẵng',
      'hồ chí minh',
      'hà nội',
      'hạ long',
      'phú quốc',
      'sapa',
      'hội an',
      'huế',
      'vũng tàu',
    ];

    return generalKeywords.any(
          (keyword) => query.toLowerCase().contains(keyword.toLowerCase()),
        ) &&
        !_isSpecificSearch(query);
  }

  bool _isSpecificSearch(String query) {
    final specificKeywords = [
      'resort',
      'hotel',
      'khách sạn',
      'nhà hàng',
      'restaurant',
      'tour',
      'spa',
      'vinpearl',
      'diamond',
      'intercontinental',
      'white rose',
      'thấp chăm',
      'po nagar',
    ];

    return specificKeywords.any(
      (keyword) => query.toLowerCase().contains(keyword.toLowerCase()),
    );
  }

  String _getSearchCategory(String query) {
    final lowerQuery = query.toLowerCase();

    if (lowerQuery.contains('resort') ||
        lowerQuery.contains('khách sạn') ||
        lowerQuery.contains('hotel') ||
        lowerQuery.contains('vinpearl')) {
      return 'hotel';
    } else if (lowerQuery.contains('nhà hàng') ||
        lowerQuery.contains('restaurant') ||
        lowerQuery.contains('white rose')) {
      return 'restaurant';
    } else if (lowerQuery.contains('tour')) {
      return 'tour';
    } else if (lowerQuery.contains('spa') ||
        lowerQuery.contains('massage') ||
        lowerQuery.contains('thấp chăm') ||
        lowerQuery.contains('po nagar')) {
      return 'activity';
    }
    return 'general';
  }

  void _navigateToSpecificPage(String query, String category) {
    switch (category) {
      case 'hotel':
        // Navigator đến trang khách sạn (tạo sau)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chuyển đến trang khách sạn: $query')),
        );
        break;
      case 'restaurant':
        // Navigator đến trang nhà hàng (tạo sau)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chuyển đến trang nhà hàng: $query')),
        );
        break;
      case 'tour':
        // Navigator đến trang tour (tạo sau)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chuyển đến trang tour: $query')),
        );
        break;
      case 'activity':
        // Navigator đến trang hoạt động (tạo sau)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chuyển đến trang hoạt động: $query')),
        );
        break;
      default:
        // Fallback to overview
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SearchOverviewScreen(searchQuery: query),
          ),
        );
    }
  }

  // Hàm xử lý tìm kiếm
  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    if (_isGeneralSearch(query)) {
      // Tìm kiếm chung chung → Trang tổng quan
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SearchOverviewScreen(searchQuery: query.trim()),
        ),
      );
    } else {
      // Tìm kiếm cụ thể → Trang category hoặc detail
      final category = _getSearchCategory(query);
      _navigateToSpecificPage(query.trim(), category);
    }
  }
}
