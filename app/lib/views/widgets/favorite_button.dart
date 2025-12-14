import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/favorite_api_service.dart';

class FavoriteButton extends StatefulWidget {
  final String serviceType; // hotel, restaurant, attraction, tour
  final int serviceId;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final bool initialIsFavorite; // Initial state

  const FavoriteButton({
    super.key,
    required this.serviceType,
    required this.serviceId,
    this.size = 24.0,
    this.activeColor,
    this.inactiveColor,
    this.initialIsFavorite = false,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool _isFavorite;
  bool _isProcessing = false;
  FavoriteApiService? _favoriteService;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.initialIsFavorite;
    _initService();
  }

  @override
  void didUpdateWidget(FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsFavorite != widget.initialIsFavorite) {
      setState(() {
        _isFavorite = widget.initialIsFavorite;
      });
    }
  }

  Future<void> _initService() async {
    final prefs = await SharedPreferences.getInstance();
    final dio = Dio();
    _favoriteService = FavoriteApiService(dio: dio, prefs: prefs);
  }

  Future<void> _toggleFavorite() async {
    if (_isProcessing || _favoriteService == null) return;

    try {
      setState(() => _isProcessing = true);

      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        Fluttertoast.showToast(
          msg: "Vui lòng đăng nhập để sử dụng tính năng này",
          backgroundColor: Colors.orange,
        );
        return;
      }

      // Optimistic update
      final previousState = _isFavorite;
      final newState = !_isFavorite;
      setState(() => _isFavorite = newState);

      try {
        if (newState) {
          // Add to favorites
          await _favoriteService!.addFavorite(
            userId: userId,
            serviceType: widget.serviceType,
            serviceId: widget.serviceId,
          );
        } else {
          // Remove from favorites
          await _favoriteService!.removeFavorite(
            userId: userId,
            serviceType: widget.serviceType,
            serviceId: widget.serviceId,
          );
        }

        // Show toast
        Fluttertoast.showToast(
          msg: newState ? "Đã thêm vào yêu thích ❤️" : "Đã xóa khỏi yêu thích",
          backgroundColor: newState ? Colors.red : Colors.grey,
        );
      } catch (apiError) {
        // Revert on API error
        if (mounted) {
          setState(() => _isFavorite = previousState);
        }
        rethrow;
      }
    } catch (e) {
      debugPrint('❌ Error toggling favorite: $e');
      Fluttertoast.showToast(
        msg: "Có lỗi xảy ra, vui lòng thử lại",
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isProcessing ? null : _toggleFavorite,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isProcessing
            ? SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.activeColor ?? Colors.red,
                ),
              )
            : Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                size: widget.size,
                color: _isFavorite
                    ? (widget.activeColor ?? Colors.red)
                    : (widget.inactiveColor ?? Colors.grey),
              ),
      ),
    );
  }
}
