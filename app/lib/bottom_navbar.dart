import 'package:flutter/material.dart';

import 'home_page.dart';
import 'tap_page.dart';
import 'contacts_page.dart';

class BottomNavbar extends StatefulWidget {
  // The main page of your application
  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  // State management for selected index
  int _selectedIndex = 0;

  // List of pages to display (now empty to prevent background content)
  final List<Widget> _pages = [
    const HomeView(),
    const TapView(),
    const ContactsPage(),
  ];

  // Handle item tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Build method to render UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Make the background transparent
      backgroundColor: Color(0xFF171717),
      // Empty body to prevent any background content
      body: _pages[_selectedIndex],
      // Custom bottom navigation bar
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          top: 8.0,
          right: 8.0,
          bottom: 30.0, // Increased bottom padding
        ), // Padding around the navigation bar
        child: Container(
          height: 60.0, // Height of the navigation bar
          decoration: BoxDecoration(
            color: Colors.black, // Background color of the navigation bar
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF171717),
                blurRadius: 4.0,
                spreadRadius: 1.0,
              ),
            ], // Shadow effect
          ),
          // Row to hold navigation items
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Navigation items
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.handshake, 'Tap', 1),
              _buildNavItem(Icons.contacts, 'Contacts', 2),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build each navigation item
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index), // Handle tap
      child: Container(
        color: Colors.transparent, // Transparent background
        padding: const EdgeInsets.symmetric(vertical: 8.0), // Vertical padding
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, // Icon data
              color: isSelected ? Colors.blue : Colors.grey, // Icon color based on selection
              size: 30.0, // Icon size
            ),
            const SizedBox(height: 4.0), // Spacing between icon and label
            Text(
              label, // Label text
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey, // Text color based on selection
                fontSize: 12.0, // Font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
