import 'package:flutter/material.dart';

class CampDetailsPage extends StatelessWidget {
  final String title;

  const CampDetailsPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Camp Details"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDetailRow("📍 Venue", "Rajkot City Center"),
            _buildDetailRow("📅 Date", "2025-07-10"),
            _buildDetailRow("💉 Blood Types Needed", "A+, B+, O+"),
            const SizedBox(height: 30),
            Text(
              "📝 Organized by: Indian Red Cross Society",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Text(
              "ℹ️ Please carry a valid ID proof. Avoid donating on an empty stomach. Drink plenty of water!",
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text("$label: $value", style: const TextStyle(fontSize: 18)),
    );
  }
}
