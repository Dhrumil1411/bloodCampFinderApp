import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us"),
        backgroundColor: Colors.red.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCard(
              icon: Icons.favorite,
              title: "Blood Camp Finder Mission",
              content:
                  "Our mission is to bridge the gap between blood donors and those in need. We aim to create a unified platform where users can find nearby blood banks, participate in donation camps, and help save lives with just a few taps.",
            ),
            const SizedBox(height: 20),
            buildCard(
              icon: Icons.group,
              title: "Our Team",
              content: '''
- Viral Sakdecha (23020201139)
- Dhrumil Dashadia (23020201038)
- Sinhal Joshi (23020201071)
''',
            ),
            const SizedBox(height: 20),
            buildCard(
              icon: Icons.location_on,
              title: "Headquarters",
              content: "Rajkot, Gujarat",
            ),
            const SizedBox(height: 20),
            buildCard(
              icon: Icons.web,
              title: "Contact & Info",
              content:
                  "Email: bloodcampfinder@support.com\nWebsite: www.bloodcampfinder.in",
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade100.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: Colors.red.shade700),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
