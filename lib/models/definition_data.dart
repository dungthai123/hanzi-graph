/// Model for character definitions data
class DefinitionData {
  final String character;
  final List<String> english;
  final String pinyin;
  final List<String> parts;
  final int hskLevel;

  const DefinitionData({
    required this.character,
    required this.english,
    required this.pinyin,
    required this.parts,
    required this.hskLevel,
  });

  factory DefinitionData.fromJson(Map<String, dynamic> json) {
    return DefinitionData(
      character: json['character'] ?? '',
      english: List<String>.from(json['english'] ?? []),
      pinyin: json['pinyin'] ?? '',
      parts: List<String>.from(json['parts'] ?? []),
      hskLevel: json['hskLevel'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'character': character, 'english': english, 'pinyin': pinyin, 'parts': parts, 'hskLevel': hskLevel};
  }
}
