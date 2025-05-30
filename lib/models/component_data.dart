/// Model for character components data
class ComponentData {
  final String character;
  final String type; // 's' for simplified, 't' for traditional
  final List<String> components; // Sub-components of this character
  final List<String> componentOf; // Characters that use this as a component

  const ComponentData({
    required this.character,
    required this.type,
    required this.components,
    required this.componentOf,
  });

  factory ComponentData.fromJson(String character, Map<String, dynamic> json) {
    return ComponentData(
      character: character,
      type: json['type'] ?? '',
      components: List<String>.from(json['components'] ?? []),
      componentOf: List<String>.from(json['componentOf'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {'character': character, 'type': type, 'components': components, 'componentOf': componentOf};
  }

  /// Check if this character has sub-components
  bool get hasComponents => components.isNotEmpty;

  /// Check if this character is used as a component in other characters
  bool get isComponentOfOthers => componentOf.isNotEmpty;

  /// Get total component count (recursive)
  int get totalComponentCount => components.length;
}
