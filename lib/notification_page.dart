import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  final List<Map<String, String>> _notifications = const [
    {"title": "Berita baru tersedia", "time": "Baru saja"},
    {"title": "Artikel favoritmu diperbarui", "time": "10 menit lalu"},
    {"title": "Selamat datang di SpaceNews Core!", "time": "1 jam lalu"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification")),
      body: ListView.separated(
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = _notifications[i];
          return ListTile(
            leading: const Icon(Icons.notifications_none),
            title: Text(item['title']!),
            subtitle: Text(item['time']!),
          );
        },
      ),
    );
  }
}