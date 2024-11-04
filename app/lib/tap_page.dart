import 'package:flutter/material.dart';
import 'views/qr_code_view.dart';
import 'views/contactless_share_view.dart';
import 'views/card_selection_view.dart';
import 'models/card_data.dart';
import 'theme/colors.dart';

class TapView extends StatefulWidget {
  const TapView({super.key});

  @override
  _TapViewState createState() => _TapViewState();
}

class _TapViewState extends State<TapView> {
  CardData? _selectedCard;

  void _showCardSelection() async {
    final selectedCard = await Navigator.push<CardData>(
      context,
      MaterialPageRoute(
        builder: (context) => const CardSelectionView(),
      ),
    );

    if (selectedCard != null) {
      setState(() => _selectedCard = selectedCard);
    }
  }

  void _showQRCode(CardData card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodeView(card: card),
      ),
    );
  }

  void _showContactlessShare(CardData card) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactlessShareView(card: card),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: GestureDetector(
                onTap: _showCardSelection,
                child: Container(
                  width: 330,
                  height: 190,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: _selectedCard == null
                      ? const Center(
                          child: Icon(
                            Icons.add,
                            color: Colors.white54,
                            size: 40,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            _selectedCard!.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
            ),
            if (_selectedCard == null)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 206),
                      SizedBox(height: 40),
                      Text(
                        "Choose Card",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned(
                left: 0,
                right: 0,
                bottom: MediaQuery.of(context).size.height * 0.14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMethodButton(
                      "Contactless",
                      Icons.contactless,
                      () => _showContactlessShare(_selectedCard!),
                    ),
                    const SizedBox(width: 40),
                    _buildMethodButton(
                      "QR Code",
                      Icons.qr_code,
                      () => _showQRCode(_selectedCard!),
                    ),
                  ],
                ),
              ),
            Positioned(
              bottom: 20,
              right: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Add help functionality
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
