import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app/config/theme/app_colors.dart';
import 'package:app/config/theme/app_text_styles.dart';
import 'package:app/services/chat_api_service.dart';
import 'package:app/views/screens/chat_with_provider_screen.dart';

/// Model đơn giản cho Provider
class ProviderInfo {
  final int providerId;
  final String companyName;
  final String? logoUrl;
  final String? address;
  final String? contactEmail;
  final String? contactPhone;
  final double? ratingOverall;
  final String? providerStatus;

  ProviderInfo({
    required this.providerId,
    required this.companyName,
    this.logoUrl,
    this.address,
    this.contactEmail,
    this.contactPhone,
    this.ratingOverall,
    this.providerStatus,
  });

  factory ProviderInfo.fromJson(Map<String, dynamic> json) {
    return ProviderInfo(
      providerId: json['providerId'] ?? json['provider_id'] ?? 0,
      companyName: json['companyName'] ?? json['company_name'] ?? 'Unknown',
      logoUrl: json['logoUrl'] ?? json['logo_url'],
      address: json['address'],
      contactEmail: json['contactEmail'] ?? json['contact_email'],
      contactPhone: json['contactPhone'] ?? json['contact_phone'],
      ratingOverall: (json['ratingOverall'] ?? json['rating_overall'])
          ?.toDouble(),
      providerStatus: json['providerStatus'] ?? json['provider_status'],
    );
  }
}

/// Screen hiển thị danh sách Provider để user chọn chat
class SelectProviderChatScreen extends StatefulWidget {
  final int userId;
  final String? subject;

  const SelectProviderChatScreen({
    super.key,
    required this.userId,
    this.subject,
  });

  @override
  State<SelectProviderChatScreen> createState() =>
      _SelectProviderChatScreenState();
}

class _SelectProviderChatScreenState extends State<SelectProviderChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<ProviderInfo> _providers = [];
  List<ProviderInfo> _filteredProviders = [];
  bool _isLoading = true;
  String? _error;
  ChatApiService? _chatService;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    debugPrint(
      '🔐 Token: ${token != null ? "${token.substring(0, 20)}..." : "NULL"}',
    );

    final dio = Dio();
    _chatService = ChatApiService(dio: dio, prefs: prefs);
    await _loadProviders();
  }

  Future<void> _loadProviders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _chatService!.getAllProviders();
      debugPrint('📦 Raw providers data: $data');

      final providers = data
          .map((json) => ProviderInfo.fromJson(json))
          .toList(); // Hiển thị tất cả providers (không filter theo status)

      debugPrint('✅ Loaded ${providers.length} providers');

      setState(() {
        _providers = providers;
        _filteredProviders = providers;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Error loading providers: $e');
      setState(() {
        _error = 'Không thể tải danh sách nhà cung cấp: $e';
        _isLoading = false;
      });
    }
  }

  void _filterProviders(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProviders = _providers);
      return;
    }

    final filtered = _providers.where((provider) {
      final name = provider.companyName.toLowerCase();
      final address = provider.address?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || address.contains(searchQuery);
    }).toList();

    setState(() => _filteredProviders = filtered);
  }

  void _onSelectProvider(ProviderInfo provider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatWithProviderScreen(
          userId: widget.userId,
          providerId: provider.providerId,
          providerName: provider.companyName,
          providerLogo: provider.logoUrl,
          subject: widget.subject ?? 'Hỗ trợ từ TripBot',
        ),
      ),
    );
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Chọn nhà cung cấp',
          style: context.h5Style.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: context.cardBackgroundColor,
            child: TextField(
              controller: _searchController,
              onChanged: _filterProviders,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nhà cung cấp...',
                hintStyle: context.bodyTwoStyle.copyWith(
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
              style: context.bodyOneStyle.copyWith(
                color: context.textPrimaryColor,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: context.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Đang tải danh sách nhà cung cấp...',
              style: context.bodyTwoStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.alertCircle, size: 48, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: context.bodyOneStyle.copyWith(
                color: context.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProviders,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredProviders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.building2,
              size: 64,
              color: context.textSecondaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Chưa có nhà cung cấp nào'
                  : 'Không tìm thấy nhà cung cấp',
              style: context.h5Style.copyWith(color: context.textPrimaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              _searchController.text.isEmpty
                  ? 'Các nhà cung cấp sẽ xuất hiện ở đây'
                  : 'Thử tìm kiếm với từ khóa khác',
              style: context.bodyTwoStyle.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProviders,
      color: context.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filteredProviders.length,
        itemBuilder: (context, index) {
          final provider = _filteredProviders[index];
          return _buildProviderCard(provider);
        },
      ),
    );
  }

  Widget _buildProviderCard(ProviderInfo provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onSelectProvider(provider),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Logo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      provider.logoUrl != null && provider.logoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            provider.logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                LucideIcons.building2,
                                size: 28,
                                color: context.primaryColor,
                              );
                            },
                          ),
                        )
                      : Icon(
                          LucideIcons.building2,
                          size: 28,
                          color: context.primaryColor,
                        ),
                ),

                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company name
                      Text(
                        provider.companyName,
                        style: context.bodyOneStyle.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Address
                      if (provider.address != null &&
                          provider.address!.isNotEmpty)
                        Row(
                          children: [
                            Icon(
                              LucideIcons.mapPin,
                              size: 14,
                              color: context.textSecondaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                provider.address!,
                                style: context.captionStyle.copyWith(
                                  color: context.textSecondaryColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 4),

                      // Rating
                      if (provider.ratingOverall != null &&
                          provider.ratingOverall! > 0)
                        Row(
                          children: [
                            Icon(
                              LucideIcons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              provider.ratingOverall!.toStringAsFixed(1),
                              style: context.captionStyle.copyWith(
                                color: context.textSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  LucideIcons.messageCircle,
                  color: context.primaryColor,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
