import 'dart:io';
import 'package:flutter/material.dart';
import 'markdown_element.dart';

/// 图片渲染组件
class MarkdownImageWidget extends MarkdownElementWidget {
  const MarkdownImageWidget({
    Key? key,
    required String rawContent,
    required MarkdownTheme theme,
  }) : super(key: key, rawContent: rawContent, theme: theme);

  @override
  Widget build(BuildContext context) {
    final imageData = _parseImageMarkdown(rawContent);
    if (imageData == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildImage(context, imageData),
          if (imageData.alt.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                imageData.alt,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  /// 解析图片Markdown格式
  ImageData? _parseImageMarkdown(String markdown) {
    final RegExp imageRegex = RegExp(r'!\[(.*?)\]\((.*?)(?:\s+"(.*?)")?\)');
    final match = imageRegex.firstMatch(markdown);
    
    if (match == null) {
      return null;
    }
    
    final alt = match.group(1) ?? '';
    final src = match.group(2) ?? '';
    final title = match.group(3) ?? '';
    
    return ImageData(
      src: src,
      alt: alt,
      title: title,
    );
  }

  /// 构建图片显示组件
  Widget _buildImage(BuildContext context, ImageData imageData) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imageData),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 300,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _getImageWidget(imageData.src),
        ),
      ),
    );
  }

  /// 根据图片路径获取对应的图片组件
  Widget _getImageWidget(String src) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      // 网络图片
      return Image.network(
        src,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      (loadingProgress.expectedTotalBytes ?? 1)
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.error,
          color: Colors.red,
          size: 50,
        ),
      );
    } else {
      // 本地图片
      try {
        return Image.file(
          File(src),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.broken_image,
            color: Colors.red,
            size: 50,
          ),
        );
      } catch (e) {
        return const Icon(
          Icons.broken_image,
          color: Colors.red,
          size: 50,
        );
      }
    }
  }

  /// 显示全屏图片
  void _showFullScreenImage(BuildContext context, ImageData imageData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              imageData.title.isNotEmpty ? imageData.title : imageData.alt,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              clipBehavior: Clip.none,
              minScale: 0.5,
              maxScale: 4.0,
              child: _getImageWidget(imageData.src),
            ),
          ),
        ),
      ),
    );
  }
}

/// 图片数据类
class ImageData {
  final String src;
  final String alt;
  final String title;

  ImageData({
    required this.src,
    this.alt = '',
    this.title = '',
  });
} 