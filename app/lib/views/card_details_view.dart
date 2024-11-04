import 'package:flutter/material.dart';
import '../models/card_details.dart';

class CardDetailsView extends StatelessWidget {
  final CardDetails details;

  const CardDetailsView({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    "${details.cardType} Details",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Card Preview
            Container(
              width: double.infinity,
              height: 190,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  details.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Card details
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: details.attributes.entries.map((entry) {
                  return _buildDetailSection(
                    title: entry.key,
                    value: entry.value,
                    icon: _getIconForAttribute(entry.key),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForAttribute(String attribute) {
    switch (attribute.toLowerCase()) {
      case 'name':
      case 'fullname':
        return Icons.person_outline;
      case 'address':
        return Icons.location_on_outlined;
      case 'phone':
      case 'phonenumber':
        return Icons.phone_outlined;
      case 'employid':
      case 'studentid':
      case 'dlno':
      case 'individualid':
        return Icons.badge_outlined;
      case 'department':
        return Icons.business_outlined;
      case 'position':
        return Icons.work_outline;
      case 'issuedate':
        return Icons.calendar_today_outlined;
      case 'expiredate':
        return Icons.timer_outlined;
      case 'born':
      case 'dob':
        return Icons.cake_outlined;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildDetailSection({
    required String title,
    required String value,
    required IconData icon,
  }) {
    // Convert snake_case or camelCase to Title Case
    String formattedTitle = title
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                formattedTitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 