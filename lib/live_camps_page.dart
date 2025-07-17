import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'blood_camp_details_page.dart';

class LiveCampsPage extends StatefulWidget {
  const LiveCampsPage({super.key});

  @override
  State<LiveCampsPage> createState() => _LiveCampsPageState();
}

class _LiveCampsPageState extends State<LiveCampsPage> {
  String? selectedState;
  String? selectedCity;
  DateTime? selectedDate;
  List<String> states = [];
  List<String> cities = [];

  @override
  void initState() {
    super.initState();
    fetchStates();
  }

  Future<void> fetchStates() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bloodbanks')
        .get();
    final uniqueStates =
        snapshot.docs
            .map((doc) => doc['state'] as String?)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    setState(() => states = uniqueStates);
  }

  Future<void> fetchCitiesForState(String state) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bloodbanks')
        .where('state', isEqualTo: state)
        .get();
    final uniqueCities =
        snapshot.docs
            .map((doc) => doc['city'] as String?)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();
    setState(() {
      cities = uniqueCities;
      selectedCity = null;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Blood Camps'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select State'),
                  value: selectedState,
                  items: states.map((state) {
                    return DropdownMenuItem(value: state, child: Text(state));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedState = value;
                      cities = [];
                      selectedCity = null;
                    });
                    if (value != null) fetchCitiesForState(value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select City'),
                  value: selectedCity,
                  items: cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedCity = value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Select Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate != null
                                    ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(selectedDate!)
                                    : 'Select a date',
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            selectedDate = null;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bloodbanks')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading camps'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final stateMatch =
                      selectedState == null || data['state'] == selectedState;
                  final cityMatch =
                      selectedCity == null || data['city'] == selectedCity;

                  if (selectedDate == null) return stateMatch && cityMatch;

                  try {
                    // Check for date range first
                    if (data['start_date'] != null &&
                        data['end_date'] != null) {
                      final startDate = DateFormat(
                        'yyyy-MM-dd',
                      ).parse(data['start_date']);
                      final endDate = DateFormat(
                        'yyyy-MM-dd',
                      ).parse(data['end_date']);
                      return stateMatch &&
                          cityMatch &&
                          (selectedDate!.isAfter(
                                startDate.subtract(const Duration(days: 1)),
                              ) &&
                              selectedDate!.isBefore(
                                endDate.add(const Duration(days: 1)),
                              ));
                    }
                    // Fall back to single date
                    else if (data['date'] != null) {
                      final campDate = DateFormat(
                        'yyyy-MM-dd',
                      ).parse(data['date']);
                      return stateMatch &&
                          cityMatch &&
                          (selectedDate!.year == campDate.year &&
                              selectedDate!.month == campDate.month &&
                              selectedDate!.day == campDate.day);
                    }
                    return false;
                  } catch (e) {
                    return false;
                  }
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.event_busy,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No active camps found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        if (selectedDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'for ${DateFormat('MMM dd, yyyy').format(selectedDate!)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final camp = filtered[index].data() as Map<String, dynamic>;
                    final campName = camp['name'] ?? 'Blood Camp';

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                BloodCampDetailsPage(campName: campName),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                campName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.location_on,
                                'Address',
                                camp['address'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                Icons.phone,
                                'Contact',
                                camp['phone'] ?? 'N/A',
                              ),
                              _buildInfoRow(
                                Icons.person,
                                'Organizer',
                                camp['organizer'] ?? campName,
                              ),
                              if (camp['start_date'] != null &&
                                  camp['end_date'] != null)
                                _buildInfoRow(
                                  Icons.calendar_today,
                                  'Date Range',
                                  '${_formatCampDate(camp['start_date'])} to ${_formatCampDate(camp['end_date'])}',
                                ),
                              if (camp['date'] != null)
                                _buildInfoRow(
                                  Icons.calendar_today,
                                  'Date',
                                  _formatCampDate(camp['date']),
                                ),
                              if (camp['time'] != null)
                                _buildInfoRow(
                                  Icons.access_time,
                                  'Time',
                                  camp['time'],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatCampDate(String dateString) {
    try {
      final date = DateFormat('yyyy-MM-dd').parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$label: $value', style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
