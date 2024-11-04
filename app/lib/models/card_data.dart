class CardData {
  final String type;
  final String image;
  final Map<String, String> attributes;

  CardData({
    required this.type,
    required this.image,
    required this.attributes,
  });

  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      type: json['type'],
      image: json['image'],
      attributes: Map<String, String>.from(json['attributes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'image': image,
      'attributes': attributes,
    };
  }
} 