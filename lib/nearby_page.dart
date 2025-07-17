import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _nearbyBloodBanks = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchNearbyBloodBanks();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _fetchNearbyBloodBanks() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bloodbanks')
        .get();

    final List<Map<String, dynamic>> banks = snapshot.docs
        .map((doc) {
          return doc.data();
        })
        .where((bank) {
          return bank.containsKey('latitude') && bank.containsKey('longitude');
        })
        .toList();

    setState(() {
      _nearbyBloodBanks = banks;
    });
  }

  void _showBloodBankDetails(Map<String, dynamic> bank) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          bank['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 5),
                Expanded(child: Text(bank['address'] ?? '')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.bloodtype, color: Colors.deepOrange),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    (bank['blood_required'] as List<dynamic>).join(", "),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, color: Colors.green),
                const SizedBox(width: 5),
                Text(bank['phone'] ?? ''),
              ],
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.call, color: Colors.green),
            label: const Text("Call"),
            onPressed: () {
              Navigator.pop(context);
              _launchDialer(bank['phone']);
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.directions, color: Colors.blue),
            label: const Text("Get Directions"),
            onPressed: () {
              Navigator.pop(context);
              _openGoogleMaps(bank['latitude'], bank['longitude']);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _launchDialer(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    print("Dial URI: $phoneUri");

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
    } else {
      print("❌ Could not launch dialer");
    }
  }

  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      final fallback = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
      if (await canLaunchUrl(fallback)) {
        await launchUrl(fallback, mode: LaunchMode.externalApplication);
      } else {
        print("Could not launch Google Maps or fallback URL.");
      }
    }
  }

  Widget _buildMapView() {
    return FlutterMap(
      options: MapOptions(
        center: _currentLocation ?? LatLng(22.3039, 70.8022), // Rajkot default
        zoom: 13,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.blood_camp_finder_project',
        ),
        if (_currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentLocation!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: 35,
                ),
              ),
            ],
          ),
        MarkerLayer(
          markers: _nearbyBloodBanks.map((bank) {
            return Marker(
              point: LatLng(bank['latitude'], bank['longitude']),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showBloodBankDetails(bank),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 35,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Blood Banks')),
      body: _buildMapView(),
    );
  }
}
