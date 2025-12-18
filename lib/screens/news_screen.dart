// lib/screens/news_screen.dart
import 'package:flutter/material.dart';
import 'package:food_recognizer_client/models/news_model.dart';
import 'package:food_recognizer_client/widgets/global_widgets/pull_to_refresh_scaffold.dart';

import '../services/news_service.dart';
import '../widgets/news_widgets/news_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<News>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = NewsService.getNews();
    _preloadNews();
  }

  Future<void> _preloadNews() async {
    await NewsService.getNews(); 
  }

  @override
  Widget build(BuildContext context) {
    return PullToRefresh(
      onRefresh: () async {
        setState(() {
          _newsFuture = NewsService.getNews();
        });
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Новости')),
        body: FutureBuilder<List<News>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            }
            final news = snapshot.data ?? [];
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: news.length,
              itemBuilder: (context, index) {
                final newsItem = news[index];
                return NewsCard(news: newsItem);
              },
            );
          },
        ),
      ),
    );
  }
}