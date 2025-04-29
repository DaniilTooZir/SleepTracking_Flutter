class Recommendation {
  final int id;
  final String text;
  final String type;

  Recommendation({required this.id, required this.text, required this.type});

  factory Recommendation.fromMap(Map<String, dynamic> map) {
    return Recommendation(
      id: map['Id'],
      text: map['RecommendText'],
      type: map['RecommendType'],
    );
  }
  Map<String, dynamic> toMap() {
    return {'Id': id,
      'RecommendText': text,
      'RecommendType': type
    };
  }
}
