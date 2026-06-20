import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_page.dart';
import 'favorite_page.dart';
import 'notification_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final _pages = const [
    _NewsFeedTab(),
    FavoritePage(),
    NotificationPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
  currentIndex: _index,
  onTap: (i) => setState(() => _index = i),

  backgroundColor: Colors.black,
  selectedItemColor: Colors.blue,
  unselectedItemColor: Colors.grey,

  type: BottomNavigationBarType.fixed,

  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: "Home",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.favorite),
      label: "Favorite",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.notifications),
      label: "Notification",
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: "Profile",
    ),
  ],
),
    );
  }
}

class _NewsFeedTab extends StatefulWidget {
  const _NewsFeedTab();

  @override
  State<_NewsFeedTab> createState() => _NewsFeedTabState();
}

class _NewsFeedTabState extends State<_NewsFeedTab> {
  List<dynamic> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  Future<void> _fetchArticles() async {
    try {
      final res = await http.get(Uri.parse(
        'https://api.spaceflightnewsapi.net/v4/articles/?limit=20',
      ));
      final data = jsonDecode(res.body);
      setState(() {
        _articles = data['results'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_articles.isEmpty) {
      return const Center(child: Text("Tidak ada berita"));
    }

    final headline = _articles.first;
    final rest = _articles.skip(1).toList();

    return RefreshIndicator(
      onRefresh: _fetchArticles,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Banner headline
          GestureDetector(
            onTap: () => _openDetail(headline),
            child: Stack(
              children: [
                Image.network(
                  headline['image_url'] ?? '',
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(height: 220, color: Colors.grey),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(
                    headline['title'] ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 6, color: Colors.black)],
                    ),
                  ),
                ),
              ],
            ),
          ),

          ...rest.map((article) => ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article['image_url'] ?? '',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(width: 70, height: 70, color: Colors.grey),
                  ),
                ),
                title: Text(
                  article['title'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(article['news_site'] ?? ''),
                onTap: () => _openDetail(article),
              )),
        ],
      ),
    );
  }

  void _openDetail(dynamic article) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(article: article)),
    );
  }
}