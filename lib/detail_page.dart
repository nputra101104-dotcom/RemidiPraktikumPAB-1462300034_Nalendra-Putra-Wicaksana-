import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPage extends StatefulWidget {
  final dynamic article;

  const DetailPage({
    super.key,
    required this.article,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false;
  String? favoriteDocId;

  @override
  void initState() {
    super.initState();
    checkFavorite();
  }

  CollectionReference get favoriteCollection =>
      FirebaseFirestore.instance.collection('favorites');

  Future<void> checkFavorite() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final result = await favoriteCollection
        .where('userId', isEqualTo: user.uid)
        .where('articleId', isEqualTo: widget.article['id'])
        .get();

    if (result.docs.isNotEmpty) {
      setState(() {
        isFavorite = true;
        favoriteDocId = result.docs.first.id;
      });
    }
  }

  Future<void> toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User belum login"),
        ),
      );
      return;
    }

    try {
      if (isFavorite && favoriteDocId != null) {
        await favoriteCollection.doc(favoriteDocId).delete();

        setState(() {
          isFavorite = false;
          favoriteDocId = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berita dihapus dari favorite"),
          ),
        );
      } else {
        final docRef = await favoriteCollection.add({
          'userId': user.uid,
          'articleId': widget.article['id'],
          'title': widget.article['title'] ?? '',
          'imageUrl': widget.article['image_url'] ?? '',
          'newsSite': widget.article['news_site'] ?? '',
          'summary': widget.article['summary'] ?? '',
          'createdAt': Timestamp.now(),
        });

        setState(() {
          isFavorite = true;
          favoriteDocId = docRef.id;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berita ditambahkan ke favorite"),
          ),
        );
      }
    } catch (e) {
      print("ERROR FAVORITE: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Berita"),
        actions: [
          IconButton(
            onPressed: toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              article['image_url'] ?? '',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 250, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                article['title'] ?? '',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                article['summary'] ?? '',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}