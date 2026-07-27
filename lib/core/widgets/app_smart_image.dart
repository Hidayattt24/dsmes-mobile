import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// A smart image widget that seamlessly handles:
/// - Base64 Data URIs (`data:image/png;base64,...`)
/// - Standard Network HTTP/HTTPS URLs
/// - Asset images
/// - Shimmer skeleton loading placeholder
/// - Graceful error fallbacks
class AppSmartImage extends StatelessWidget {
  const AppSmartImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackIcon = Icons.image_outlined,
    this.fallbackColor,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData fallbackIcon;
  final Color? fallbackColor;

  bool get _isBase64 => imageUrl.startsWith('data:image/');

  Uint8List? _decodeBase64(String dataUri) {
    try {
      final base64Str = dataUri.split(',').last;
      return base64Decode(base64Str);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl.trim().isEmpty) {
      imageWidget = _buildFallback();
    } else if (_isBase64) {
      final bytes = _decodeBase64(imageUrl);
      if (bytes != null && bytes.isNotEmpty) {
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      } else {
        imageWidget = _buildFallback();
      }
    } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      imageWidget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmerPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else if (imageUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else {
      imageWidget = _buildFallback();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surfaceContainerLowest,
      child: Container(
        width: width,
        height: height,
        color: AppColors.surfaceContainerHigh,
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: fallbackColor ?? AppColors.surfaceContainerHigh,
      child: Center(
        child: Icon(
          fallbackIcon,
          size: (height != null && height! < 100) ? 32 : 48,
          color: AppColors.outline,
        ),
      ),
    );
  }
}
