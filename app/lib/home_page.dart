import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'views/card_details_view.dart';
import 'models/card_details.dart';
import 'data/cards_data.dart';
import 'models/card_data.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();
  final ScrollController _tagScrollController = ScrollController();
  final List<String> _tags = cardsData.map((card) => card.type).toList();

  void _navigateToTapView() {
    // Navigate to TapView
    print('Navigating to TapView');
  }

  void _showCardDetails() {
    final CardData currentCard = cardsData[_currentIndex];
    
    final cardDetails = CardDetails(
      cardType: currentCard.type,
      attributes: currentCard.attributes,
      image: currentCard.image,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardDetailsView(details: cardDetails),
      ),
    );
  }

  void _scrollToSelectedTag(int index) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double tagWidth = 100.0; // Approximate width of each tag
    final double padding = 10.0; // Horizontal padding of each tag
    
    // Calculate the target scroll offset
    double targetOffset = (tagWidth + padding * 2) * index - (screenWidth - tagWidth) / 2;
    
    // Ensure the offset is within bounds
    targetOffset = targetOffset.clamp(
      0.0,
      _tagScrollController.position.maxScrollExtent,
    );

    // Animate to the target offset
    _tagScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onCarouselPageChanged(int index, CarouselPageChangedReason reason) {
    setState(() {
      _currentIndex = index;
      _scrollToSelectedTag(index);
    });
  }

  @override
  void dispose() {
    _tagScrollController.dispose(); // Clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      backgroundColor: const Color(0xFF171717),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            // Add functionality later
                            print('Plus button pressed');
                          },
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Add functionality later
                            print('Settings button pressed');
                          },
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Welcome \nJane Doe",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Add My Cards section header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    const Text(
                      "My Cards",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_tags.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 50,
                child: SingleChildScrollView(
                  controller: _tagScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_tags.length, (index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                            _carouselController.animateToPage(index);
                            _scrollToSelectedTag(index);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? Colors.lightBlue
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _tags[index],
                            style: TextStyle(
                              color: _currentIndex == index
                                  ? Colors.white
                                  : Colors.grey.shade400,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                child: CarouselSlider(
                  carouselController: _carouselController,
                  options: CarouselOptions(
                    height: 190,
                    viewportFraction: 0.85,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.2,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: _onCarouselPageChanged,
                  ),
                  items: cardsData.map((card) {
                    return ClipRRect( // Added ClipRRect for rounded corners
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        card.image,
                        fit: BoxFit.fitWidth,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: _showCardDetails,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Show detail',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}