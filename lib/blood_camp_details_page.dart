import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BloodCampDetailsPage extends StatelessWidget {
  final String campName;

  const BloodCampDetailsPage({super.key, required this.campName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Camp Details'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('bloodbanks')
            .where('name', isEqualTo: campName)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Camp not found.'));
          }

          final camp = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          final name = camp['name'] ?? 'Not available';
          final organizer = camp['organized_by'] ?? 'Not available';
          final address = camp['address'] ?? 'Not available';
          final phone = camp['phone'] ?? 'Not available';
          final city = camp['city'] ?? 'N/A';
          final state = camp['state'] ?? 'N/A';
          final startDate = camp['start_date'] ?? 'N/A';
          final endDate = camp['end_date'] ?? 'N/A';
          final hours = camp['hours_active'] ?? 'N/A';
          final bloodTypes =
              (camp['blood_required'] as List<dynamic>?)?.join(', ') ?? 'N/A';
          final isCamp = camp['is_blood_camp'] == true;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bloodtype, color: Colors.red, size: 40),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailTile(Icons.group, 'Organizer', organizer),
                _buildDetailTile(Icons.location_on, 'Address', address),
                _buildDetailTile(Icons.phone, 'Contact Number', phone),
                _buildDetailTile(Icons.location_city, 'City', city),
                _buildDetailTile(Icons.map, 'State', state),
                _buildDetailTile(Icons.calendar_today, 'Start Date', startDate),
                _buildDetailTile(
                  Icons.calendar_today_outlined,
                  'End Date',
                  endDate,
                ),
                _buildDetailTile(Icons.access_time, 'Hours Active', hours),
                _buildDetailTile(
                  Icons.bloodtype_outlined,
                  'Blood Required',
                  bloodTypes,
                ),
                _buildDetailTile(
                  Icons.event,
                  'Camp Type',
                  isCamp ? 'Blood Donation Camp' : 'Permanent Blood Bank',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
