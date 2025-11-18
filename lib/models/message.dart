class Message {
  final int id;
  final int threadId;
  final int userId;
  final String body;
  final String filename;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  Message({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.body,
    required this.filename,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      return Message(
        id: json['id'] as int,
        threadId: json['thread_id'] as int,
        userId: json['user_id'] as int,
        body: json['body'] as String? ?? '',
        filename: json['filename'] as String? ?? '',
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : DateTime.now(),
        user: json['user'] != null ? User.fromJson(json['user']) : null,
      );
    } catch (e) {
      print('❌ Erreur parsing Message: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}

class User {
  final int id;
  final String name;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Utilisateur',
      photoUrl: json['photo_url'] as String?,
    );
  }
}

class MessageResponse {
  final bool success;
  final String? message;
  final MessageResult result;

  MessageResponse({
    required this.success,
    this.message,
    required this.result,
  });

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      result: MessageResult.fromJson(json['result']),
    );
  }
}

class MessageResult {
  final List<Message> data;

  MessageResult({required this.data});

  factory MessageResult.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return MessageResult(
      data: dataList.map((item) => Message.fromJson(item)).toList(),
    );
  }
}
