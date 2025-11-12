// To parse this JSON data, do
//
//     final newsEntry = newsEntryFromJson(jsonString);

import 'dart:convert';

List<NewsEntry> newsEntryFromJson(String str) => List<NewsEntry>.from(json.decode(str).map((x) => NewsEntry.fromJson(x)));

String newsEntryToJson(List<NewsEntry> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NewsEntry {
    String id;
    String title;
    String content;
    String category;
    String? thumbnail; // <-- UBAH KE String?
    int newsViews;
    DateTime createdAt;
    bool isFeatured;
    int userId;

    NewsEntry({
        required this.id,
        required this.title,
        required this.content,
        required this.category,
        this.thumbnail, // <-- HILANGKAN 'required'
        required this.newsViews,
        required this.createdAt,
        required this.isFeatured,
        required this.userId,
    });

    factory NewsEntry.fromJson(Map<String, dynamic> json) => NewsEntry(
        id: json["id"] ?? "",
        title: json["title"] ?? "No Title",
        content: json["content"] ?? "No Content",
        category: json["category"] ?? "update",
        thumbnail: json["thumbnail"] as String?, // <-- CAST ke String?
        newsViews: json["news_views"] ?? 0,
        createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
        isFeatured: json["is_featured"] ?? false,
        userId: json["user_id"] ?? 0,
    );
    
    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "content": content,
        "category": category,
        "thumbnail": thumbnail,
        "news_views": newsViews,
        "created_at": createdAt.toIso8601String(),
        "is_featured": isFeatured,
        "user_id": userId,
    };
}
