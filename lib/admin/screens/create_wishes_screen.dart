import 'package:flutter/material.dart';

class CreateWishesScreen extends StatelessWidget {
  const CreateWishesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryMaroon = Color(0xFF8B0000);
    const Color backgroundColor = Color(0xFFFFF8F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text(
          'Create Wishes',
          style: TextStyle(color: primaryMaroon, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryMaroon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 80, color: primaryMaroon.withOpacity(0.2)),
            const SizedBox(height: 16),
            const Text(
              'Wishes & Events Form Coming Soon',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5A403C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
