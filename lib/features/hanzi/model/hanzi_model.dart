/// Hanzi definition model
class HanziDefinition {
  final String character;
  final List<String> english;
  final String pinyin;
  final List<String> parts;
  final int hskLevel;

  const HanziDefinition({
    required this.character,
    required this.english,
    required this.pinyin,
    required this.parts,
    required this.hskLevel,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HanziDefinition && runtimeType == other.runtimeType && character == other.character;

  @override
  int get hashCode => character.hashCode;
}

/// Hanzi sentence model
class HanziSentence {
  final String chinese;
  final String english;
  final String pinyin;
  final List<String> characters;
  final String source;

  const HanziSentence({
    required this.chinese,
    required this.english,
    required this.pinyin,
    required this.characters,
    required this.source,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is HanziSentence && runtimeType == other.runtimeType && chinese == other.chinese;

  @override
  int get hashCode => chinese.hashCode;
}

/// Hanzi component model
class HanziComponent {
  final String character;
  final List<String> components;
  final List<String> componentOf;
  final String strokes;
  final String radical;

  const HanziComponent({
    required this.character,
    required this.components,
    required this.componentOf,
    required this.strokes,
    required this.radical,
  });

  /// Create from JSON data
  factory HanziComponent.fromJson(String character, Map<String, dynamic> json) {
    return HanziComponent(
      character: character,
      components: (json['components'] as List?)?.map((e) => e.toString()).toList() ?? [],
      componentOf: (json['componentOf'] as List?)?.map((e) => e.toString()).toList() ?? [],
      strokes: json['strokes']?.toString() ?? '',
      radical: json['radical']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HanziComponent && runtimeType == other.runtimeType && character == other.character;

  @override
  int get hashCode => character.hashCode;
}

/// Complete hanzi details model
class HanziDetails {
  final String character;
  final HanziDefinition? definition;
  final List<HanziSentence> sentences;
  final HanziComponent? component;
  final List<String> components;
  final List<String> compounds;

  const HanziDetails({
    required this.character,
    required this.definition,
    required this.sentences,
    required this.component,
    required this.components,
    required this.compounds,
  });

  bool get hasDefinition => definition != null;
  bool get hasSentences => sentences.isNotEmpty;
  bool get hasComponents => components.isNotEmpty;
  bool get hasCompounds => compounds.isNotEmpty;
}
