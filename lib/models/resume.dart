class Resume {
  final int id;
  final String filename;
  final String? path;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Resume({
    required this.id,
    required this.filename,
    this.path,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Resume.fromJson(Map<String, dynamic> json) {
    return Resume(
      id: json['id'] ?? 0,
      filename: json['filename'] ?? '',
      path: json['path'],
      userId: json['user_id'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'path': path,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ResumeResponse {
  final bool success;
  final String message;
  final ResumeResult result;

  ResumeResponse({
    required this.success,
    required this.message,
    required this.result,
  });

  factory ResumeResponse.fromJson(Map<String, dynamic> json) {
    return ResumeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      result: ResumeResult.fromJson(json['result'] ?? {}),
    );
  }
}

class ResumeResult {
  final List<Resume> data;
  final int total;

  ResumeResult({
    required this.data,
    required this.total,
  });

  factory ResumeResult.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List? ?? [];
    List<Resume> resumes = dataList.map((item) => Resume.fromJson(item)).toList();
    
    return ResumeResult(
      data: resumes,
      total: json['total'] ?? 0,
    );
  }
}
