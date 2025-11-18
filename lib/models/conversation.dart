import 'message.dart';

class Conversation {
  final int id;
  final String subject;
  final int? postId;
  final int userId;
  final int toUserId;
  final bool isUnread;
  final bool isImportant;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;
  final User? toUser;
  final Message? latestMessage;
  final int messagesCount;

  Conversation({
    required this.id,
    required this.subject,
    this.postId,
    required this.userId,
    required this.toUserId,
    required this.isUnread,
    required this.isImportant,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.toUser,
    this.latestMessage,
    required this.messagesCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    try {
      return Conversation(
        id: json['id'] as int,
        subject: json['subject'] as String? ?? '',
        postId: json['post_id'] as int?,
        userId: json['user_id'] as int? ?? 0,
        toUserId: json['to_user_id'] as int? ?? 0,
        isUnread: json['is_unread'] == 1 || json['is_unread'] == true,
        isImportant: json['is_important'] == 1 || json['is_important'] == true,
        isArchived: json['is_archived'] == 1 || json['is_archived'] == true,
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString())
            : DateTime.now(),
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        toUser: json['to_user'] != null ? User.fromJson(json['to_user']) : null,
        latestMessage: json['latest_message'] != null 
            ? Message.fromJson(json['latest_message']) 
            : null,
        messagesCount: json['messages_count'] as int? ?? 0,
      );
    } catch (e) {
      print('❌ Erreur parsing Conversation: $e');
      print('JSON: $json');
      rethrow;
    }
  }
}

class ConversationResponse {
  final bool success;
  final String? message;
  final ConversationResult result;

  ConversationResponse({
    required this.success,
    this.message,
    required this.result,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      result: ConversationResult.fromJson(json['result']),
    );
  }
}

class ConversationResult {
  final List<Conversation> data;
  final Links links;
  final Meta meta;

  ConversationResult({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory ConversationResult.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>? ?? [];
    return ConversationResult(
      data: dataList.map((item) => Conversation.fromJson(item)).toList(),
      links: Links.fromJson(json['links'] ?? {}),
      meta: Meta.fromJson(json['meta'] ?? {}),
    );
  }
}

class Links {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  Links({this.first, this.last, this.prev, this.next});

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }
}

class Meta {
  final int currentPage;
  final int lastPage;
  final int total;

  Meta({
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      total: json['total'] as int? ?? 0,
    );
  }
}

class ConversationDetailResponse {
  final bool success;
  final String? message;
  final Conversation result;

  ConversationDetailResponse({
    required this.success,
    this.message,
    required this.result,
  });

  factory ConversationDetailResponse.fromJson(Map<String, dynamic> json) {
    return ConversationDetailResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      result: Conversation.fromJson(json['result']),
    );
  }
}
