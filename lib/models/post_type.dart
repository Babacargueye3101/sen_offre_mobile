class PostType {
  final int id;
  final String name;
  final bool active;

  PostType({
    required this.id,
    required this.name,
    required this.active,
  });

  factory PostType.fromJson(Map<String, dynamic> json) {
    return PostType(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      active: json['active'] == 1 || json['active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'active': active,
    };
  }
}

class PostTypeResponse {
  final bool success;
  final String? message;
  final PostTypeResult result;

  PostTypeResponse({
    required this.success,
    this.message,
    required this.result,
  });

  factory PostTypeResponse.fromJson(Map<String, dynamic> json) {
    return PostTypeResponse(
      success: json['success'] ?? false,
      message: json['message'],
      result: PostTypeResult.fromJson(json['result'] ?? {}),
    );
  }
}

class PostTypeResult {
  final List<PostType> data;

  PostTypeResult({
    required this.data,
  });

  factory PostTypeResult.fromJson(Map<String, dynamic> json) {
    return PostTypeResult(
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => PostType.fromJson(item))
          .toList() ?? [],
    );
  }
}
