class NoticeDetail {
  final int? id;
  final String title;
  final String content;
  final String createdAt;

  NoticeDetail({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory NoticeDetail.fromJson(Map<String, dynamic> json) {
    return NoticeDetail(
      id: json['id'] ?? -1,
      title: json['title'] ?? "",
      content: json['content'] ?? "",
      createdAt: json['createdAt'] ?? "",
    );
  }
}


