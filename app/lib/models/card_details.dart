import 'card_data.dart';

class CardDetails {
  final String cardType;
  final Map<String, String> attributes;
  final String image;

  CardDetails({
    required this.cardType,
    required this.attributes,
    required this.image,
  });

  factory CardDetails.fromCardData(CardData card) {
    return CardDetails(
      cardType: card.type,
      attributes: card.attributes,
      image: card.image,
    );
  }
} 