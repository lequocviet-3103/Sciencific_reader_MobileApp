class RecentPaper {
  final String fileName;
  final String savedPath;
  final String createdAt;

  const RecentPaper({
    required this.fileName,
    required this.savedPath,
    required this.createdAt,
  });

  factory RecentPaper.fromJson(Map<String, dynamic> json) {
    return RecentPaper(
      fileName: json["fileName"] as String? ?? "",
      savedPath: json["savedPath"] as String? ?? "",
      createdAt: json["createdAt"] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fileName": fileName,
      "savedPath": savedPath,
      "createdAt": createdAt,
    };
  }
}
