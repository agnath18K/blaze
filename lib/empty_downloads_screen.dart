import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyDownloadsScreen extends StatelessWidget {
  const EmptyDownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
              'assets/animations/empty.json'), // Path to your Lottie file
          const SizedBox(height: 20),
          const Text(
            'No Downloads Available',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add a download to get started!',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
