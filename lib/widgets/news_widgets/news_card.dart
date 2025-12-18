// lib/widgets/news_widgets/news_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:food_recognizer_client/models/news_model.dart';
import 'package:food_recognizer_client/services/news_service.dart';

class NewsCard extends StatefulWidget {
  final News news;

  const NewsCard({super.key, required this.news});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _isLiked = false;
  int _likeCount = 0;
  int _viewCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.news.likeCount;
    _viewCount = widget.news.viewCount;
    _recordView();
  }

  Future<void> _recordView() async {
    try {
      await NewsService.viewNews(widget.news.id);
      if (mounted) {
        setState(() {
          _viewCount += 1;
        });
      }
    } catch (e) {
      // Можно показать snackbar, но пока тихо
    }
  }

  Future<void> _toggleLike() async {
    try {
      if (_isLiked) {
        // Убрать лайк — пока не поддерживается API, пропустим
        return;
      }
      await NewsService.likeNews(widget.news.id);
      if (mounted) {
        setState(() {
          _isLiked = true;
          _likeCount += 1;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось поставить лайк')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение (если есть)
          if (widget.news.imageUrl != null)
            SizedBox(
              height: 160,
              child: CachedNetworkImage(
                imageUrl: widget.news.imageUrl!,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, size: 48),
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),

          // Контент
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Text(
                  widget.news.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Превью
                Text(
                  widget.news.preview,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.4,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Статистика: просмотры и лайки
                Row(
                  children: [
                    // Просмотры
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_viewCount',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Лайки
                    GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        children: [
                          Icon(
                            _isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: _isLiked ? Colors.red : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_likeCount',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}