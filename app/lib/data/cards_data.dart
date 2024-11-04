import 'dart:convert';
import '../models/card_data.dart';

final List<CardData> cardsData = [
  CardData(
    type: "My Number",
    image: "assets/images/NationalID.jpg",
    attributes: {
      "name": "Jane Doe",
      "address": "3-4-1 Okubo, Shinjuku-ku, Tokyo-to",
      "individualId": "123456789012",
      "born": "01/01/2000",
      "expireDate": "01/04/2029",
      "sex": "Female",
      "issuedBy": "Japanese Government",
    },
  ),
  CardData(
    type: "Student ID",
    image: "assets/images/StudentID.jpg",
    attributes: {
      "studiesAt": "Mediocre University C",
      "name": "Jane Doe",
      "department": "Mathematics",
      "born": "01/01/2000",
      "issueDate": "01/04/2018",
      "studentId": "123456789",
    },
  ),
  CardData(
    type: "Driving License",
    image: "assets/images/dlcard.jpeg",
    attributes: {
      "address": "3-4-1 Okubo Shinjuku Tokyo",
      "name": "Jane Doe",
      "dlNo": "1029384756",
      "type": "AT Only",
      "dob": "01/01/2000",
      "expireDate": "01/05/2025",
      "issueDate": "01/05/2020",
    },
  ),
  CardData(
    type: "Employee",
    image: "assets/images/jobcard.jpeg",
    attributes: {
      "employid": "JD12345",
      "fullname": "Jane Doe",
      "position": "Pastry Chef",
      "department": "Bakery",
      "issueDate": "2024.04.01",
      "expireDate": "2025.04.01",
    },
  ),
  CardData(
    type: "Voucher",
    image: "assets/images/vouchercard.jpeg",
    attributes: {
      "discount": "20%",
      "items": "all",
      "expireDate": "2025.01.01",
    },
  ),
];

// For QR code generation and scanning
String cardDataToJson(CardData card) {
  return json.encode(card.toJson());
}

CardData cardDataFromJson(String jsonString) {
  final Map<String, dynamic> json = jsonDecode(jsonString);
  return CardData.fromJson(json);
} 