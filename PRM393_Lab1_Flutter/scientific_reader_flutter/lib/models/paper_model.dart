class PaperModel {
  final String title;
  final String abstract;
  final String introduction;
  final String methods;
  final String results;
  final String discussion;
  final List<dynamic> concepts;

  PaperModel({
    required this.title,
    required this.abstract,
    required this.introduction,
    required this.methods,
    required this.results,
    required this.discussion,
    required this.concepts,
  });

  factory PaperModel.fromJson(Map<String, dynamic> json) {
    return PaperModel(
      title: json["title"] ?? "",
      abstract: json["abstract"] ?? "",
      introduction: json["introduction"] ?? "",
      methods: json["methods"] ?? "",
      results: json["results"] ?? "",
      discussion: json["discussion"] ?? "",
      concepts: json["concepts"] ?? [],
    );
  }
}
