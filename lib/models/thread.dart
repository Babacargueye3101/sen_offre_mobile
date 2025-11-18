import 'post.dart';

class Thread {
  final int id;
  final String body;
  final int postId;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Post? post; // Embedded post data

  Thread({
    required this.id,
    required this.body,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.post,
  });

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      postId: json['post_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      post: json['post'] != null ? Post.fromJson(json['post']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'post_id': postId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // Note: post is not serialized here as Post model doesn't have toJson
    };
  }
}

class ThreadResponse {
  final bool success;
  final String message;
  final ThreadResult result;

  ThreadResponse({
    required this.success,
    required this.message,
    required this.result,
  });

  factory ThreadResponse.fromJson(Map<String, dynamic> json) {
    return ThreadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      result: ThreadResult.fromJson(json['result'] ?? {}),
    );
  }
}

class ThreadResult {
  final List<Thread> data;
  final int total;

  ThreadResult({
    required this.data,
    required this.total,
  });

  factory ThreadResult.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    List<Thread> threads = dataList.map((item) => Thread.fromJson(item)).toList();
    
    return ThreadResult(
      data: threads,
      total: json['total'] ?? 0,
    );
  }
}
