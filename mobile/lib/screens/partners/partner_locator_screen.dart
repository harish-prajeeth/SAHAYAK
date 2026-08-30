import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/partner_provider.dart';
import '../../models/partner.dart';

class PartnerLocatorScreen extends StatefulWidget {
  const PartnerLocatorScreen({super.key});
  @override
  State<PartnerLocatorScreen> createState() => _PartnerLocatorScreenState();
}

class _PartnerLocatorScreenState extends State<PartnerLocatorScreen> {
  Position? _currentPosition;
  bool _locationLoading = false;
  String _selectedScheme = 'MFS';
  String? _locationError;

  final Map<String, String> _schemeOptions = {
    'MFS': 'Micro Finance (MFS)',
    'TL': 'Term Loan (TL)',
    'ELS': 'Education Loan (ELS)',
    'AMY': 'Aajeevika (AMY)',
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() { _locationLoading = true; _locationError = null; });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _locationError = 'Location permission denied'; _locationLoading = false; });
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() { _currentPosition = position; _locationLoading = false; });

      _searchNearby();
    } catch (e) {
      // Use default location (Chennai) if geolocation fails
      setState(() {
        _currentPosition = Position(
          latitude: 13.0827, longitude: 80.2707,
          timestamp: DateTime.now(), accuracy: 0, altitude: 0,
          heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
        );
        _locationError = 'Using default location (Chennai)';
        _locationLoading = false;
      });
      _searchNearby();
    }
  }

  void _searchNearby() {
    if (_currentPosition == null) return;
    final partnerProvider = Provider.of<PartnerProvider>(context, listen: false);
    partnerProvider.findNearbyPartners(_currentPosition!.latitude, _currentPosition!.longitude, _selectedScheme);
  }

  @override
  Widget build(BuildContext context) {
    final partnerProvider = Provider.of<PartnerProvider>(context);
    final partners = partnerProvider.nearbyPartners.map((p) => Partner.fromJson(p)).toList();

    return SafeArea(
      child: Column(
        children: [
          // Location header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentPosition != null
                            ? '📍 ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                            : 'Getting location...',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location, size: 20),
                      onPressed: _getCurrentLocation,
                    ),
                  ],
                ),
                if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(_locationError!, style: const TextStyle(fontSize: 12, color: Colors.orange)),
                  ),
              ],
            ),
          ),

          // Scheme filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text('Scheme: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedScheme,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _schemeOptions.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedScheme = v);
                        _searchNearby();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Partner list
          Expanded(
            child: _locationLoading
                ? const Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [CircularProgressIndicator(), SizedBox(height: 12), Text('Finding nearby partners...')],
                  ))
                : partners.isEmpty
                    ? const Center(child: Text('No partners found nearby'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: partners.length,
                        itemBuilder: (context, index) {
                          final partner = partners[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(partner.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Text(partner.typeLabel, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                          ],
                                        ),
                                      ),
                                      if (partner.distance != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(partner.distanceFormatted, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                        ),
                                    ],
                                  ),
                                  if (partner.address != null) ...[
                                    const SizedBox(height: 8),
                                    Row(children: [Icon(Icons.place, size: 14, color: Colors.grey[500]), const SizedBox(width: 4), Expanded(child: Text(partner.address!, style: const TextStyle(fontSize: 12)))]),
                                  ],
                                  if (partner.phone != null) ...[
                                    const SizedBox(height: 4),
                                    Row(children: [Icon(Icons.phone, size: 14, color: Colors.grey[500]), const SizedBox(width: 4), Text(partner.phone!, style: const TextStyle(fontSize: 12))]),
                                  ],
                                  const SizedBox(height: 12),

                                  // Eligibility status
                                  Row(
                                    children: [
                                      _StatusBadge(label: 'Fund: ${partner.fundUtilization.toStringAsFixed(0)}%', good: partner.fundUtilization >= 80),
                                      const SizedBox(width: 8),
                                      _StatusBadge(label: 'NPA: ${partner.npaRate.toStringAsFixed(1)}%', good: partner.npaRate < 10),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: partner.isEligible ? Colors.green[50] : Colors.red[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          partner.isEligible ? '✅ Eligible' : '❌ Not Eligible',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: partner.isEligible ? Colors.green[700] : Colors.red[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool good;
  const _StatusBadge({required this.label, required this.good});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: good ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: good ? Colors.green[700] : Colors.red[700])),
    );
  }
}
