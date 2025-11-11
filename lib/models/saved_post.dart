import 'post.dart';

class SavedPostResponse {
  final bool success;
  final String? message;
  final SavedPostResult result;

  SavedPostResponse({
    required this.success,
    this.message,
    required this.result,
  });

  factory SavedPostResponse.fromJson(Map<String, dynamic> json) {
    return SavedPostResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      result: SavedPostResult.fromJson(json['result'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'result': result.toJson(),
    };
  }
}

class SavedPostResult {
  final List<SavedPost> data;

  SavedPostResult({
    required this.data,
  });

  factory SavedPostResult.fromJson(Map<String, dynamic> json) {
    return SavedPostResult(
      data: (json['data'] as List<dynamic>)
          .map((item) => SavedPost.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class SavedPost {
  final int id;
  final int userId;
  final int postId;
  final Post post;

  SavedPost({
    required this.id,
    required this.userId,
    required this.postId,
    required this.post,
  });

  factory SavedPost.fromJson(Map<String, dynamic> json) {
    return SavedPost(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      postId: json['post_id'] as int,
      post: Post.fromJson(json['post'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      // Note: Post toJson() non implémenté, utiliser fromJson si nécessaire
    };
  }
}
