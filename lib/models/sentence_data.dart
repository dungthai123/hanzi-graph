/// Model for sentence examples data
class SentenceData {
  final String chinese;
  final String english;
  final String pinyin;
  final List<String> characters;
  final String source;

  const SentenceData({
    required this.chinese,
    required this.english,
    required this.pinyin,
    required this.characters,
    required this.source,
  });

  factory SentenceData.fromJson(Map<String, dynamic> json) {
    return SentenceData(
      chinese: json['chinese'] ?? '',
      english: json['english'] ?? '',
      pinyin: json['pinyin'] ?? '',
      characters: List<String>.from(json['characters'] ?? []),
      source: json['source'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'chinese': chinese, 'english': english, 'pinyin': pinyin, 'characters': characters, 'source': source};
  }
}
