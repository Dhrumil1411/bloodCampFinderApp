import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FAQs / Tips"),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          faqItem(
            question: "💡 Who can donate blood?",
            answer: "Anyone aged 18–65, healthy and weighing at least 50kg.",
          ),
          faqItem(
            question: "💡 How often can you donate?",
            answer: "Every 3 months for males, every 4 months for females.",
          ),
          faqItem(
            question: "💡 What to do before donating?",
            answer: "Stay hydrated, eat light, and get enough sleep.",
          ),
          faqItem(
            question: "💡 Is it safe to donate blood?",
            answer: "Absolutely. All equipment is sterile and used once only.",
          ),
        ],
      ),
    );
  }

  Widget faqItem({required String question, required String answer}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(answer, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
