/// Model for Chinese character (Hanzi) data
class HanziData {
  final String character;
  final String pronunciation;
  final List<String> definitions;
  final int frequency;
  final List<String> components;
  final Map<String, dynamic> graphData;

  const HanziData({
    required this.character,
    required this.pronunciation,
    required this.definitions,
    required this.frequency,
    required this.components,
    required this.graphData,
  });

  factory HanziData.fromJson(Map<String, dynamic> json) {
    return HanziData(
      character: json['character'] ?? '',
      pronunciation: json['pronunciation'] ?? '',
      definitions: List<String>.from(json['definitions'] ?? []),
      frequency: json['frequency'] ?? 0,
      components: List<String>.from(json['components'] ?? []),
      graphData: json['graphData'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'character': character,
      'pronunciation': pronunciation,
      'definitions': definitions,
      'frequency': frequency,
      'components': components,
      'graphData': graphData,
    };
  }
}
