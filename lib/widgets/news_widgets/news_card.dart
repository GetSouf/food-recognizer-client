// lib/widgets/news_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:food_recognizer_client/models/news_model.dart';
import 'package:food_recognizer_client/services/news_service.dart';

class NewsCard extends StatefulWidget {
  final News news;

  const NewsCard({super.key, required this.news});

  @override
  _NewsCardState createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  @override
  void initState() {
    super.initState();
    _recordView(); // Записываем просмотр при монтировании
  }

  Future<void> _recordView() async {
    try {
      await NewsService.viewNews(widget.news.id);
    } catch (e) {
      print('Failed to record view: $e'); // Логируем ошибку для отладки
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.news.imageUrl != null)
            CachedNetworkImage(
              imageUrl: widget.news.imageUrl!,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.news.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(widget.news.preview, style: theme.textTheme.bodySmall),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.visibility, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text('${widget.news.viewCount}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.favorite_border, size: 16), 
                          onPressed: () {
                            print('Like action disabled for now');
                          },
                        ),
                        Text('${widget.news.likeCount}', style: theme.textTheme.bodySmall),
                      ],
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