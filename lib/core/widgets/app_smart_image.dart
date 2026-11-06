import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/app_colors.dart';

/// A smart image widget that seamlessly handles:
/// - Base64 Data URIs (`data:image/png;base64,...`)
/// - Standard Network HTTP/HTTPS URLs
/// - Asset images
/// - Shimmer skeleton loading placeholder
/// - Graceful error fallbacks
Uint8List? _decodeImageDataUri(String dataUri) {
  try {
    if (dataUri.length > 11 * 1024 * 1024) return null;
    final comma = dataUri.indexOf(',');
    if (comma < 0) return null;
    final bytes = base64Decode(dataUri.substring(comma + 1));
    return bytes.lengthInBytes <= 8 * 1024 * 1024 ? bytes : null;
  } catch (_) {
    return null;
  }
}

class AppSmartImage extends StatefulWidget {
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

  @override
  State<AppSmartImage> createState() => _AppSmartImageState();
}

class _AppSmartImageState extends State<AppSmartImage> {
  Future<Uint8List?>? _decodedBytes;
  double? get _finiteWidth =>
      widget.width != null && widget.width!.isFinite ? widget.width : null;

  @override
  void initState() {
    super.initState();
    _prepareImage();
  }

  @override
  void didUpdateWidget(covariant AppSmartImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) _prepareImage();
  }

  void _prepareImage() {
    _decodedBytes =
        widget.imageUrl.startsWith('data:image/')
            ? compute(_decodeImageDataUri, widget.imageUrl)
            : null;
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    // Callers may request double.infinity to fill their parent. Image decoding
    // needs a finite pixel width even when layout uses an expanding width.
    final finiteWidth = _finiteWidth;
    final displayWidth = finiteWidth ?? MediaQuery.sizeOf(context).width;
    final decodeWidth = (displayWidth * pixelRatio).round().clamp(1, 1200);

    if (widget.imageUrl.trim().isEmpty) {
      imageWidget = _buildFallback();
    } else if (_decodedBytes != null) {
      imageWidget = FutureBuilder<Uint8List?>(
        future: _decodedBytes,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return snapshot.connectionState == ConnectionState.done
                ? _buildFallback()
                : _buildShimmerPlaceholder();
          }
          return Image.memory(
            snapshot.data!,
            width: finiteWidth,
            height: widget.height,
            cacheWidth: decodeWidth,
            fit: widget.fit,
            errorBuilder: (context, error, stackTrace) => _buildFallback(),
          );
        },
      );
    } else if (widget.imageUrl.startsWith('http://') ||
        widget.imageUrl.startsWith('https://')) {
      imageWidget = Image.network(
        widget.imageUrl,
        width: _finiteWidth,
        height: widget.height,
        cacheWidth: decodeWidth,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmerPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else if (widget.imageUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        widget.imageUrl,
        width: finiteWidth,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    } else {
      imageWidget = _buildFallback();
    }

    if (widget.borderRadius != null) {
      return ClipRRect(borderRadius: widget.borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainerHigh,
      highlightColor: AppColors.surfaceContainerLowest,
      child: Container(
        width: _finiteWidth,
        height: widget.height,
        color: AppColors.surfaceContainerHigh,
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: _finiteWidth,
      height: widget.height,
      decoration: BoxDecoration(
        color:
            widget.fallbackColor ??
            AppColors.primaryContainer.withValues(alpha: 0.18),
      ),
      child: Center(
        child: Icon(
          widget.fallbackIcon,
          size: (widget.height != null && widget.height! < 100) ? 32 : 44,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
