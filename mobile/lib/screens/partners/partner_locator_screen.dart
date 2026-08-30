import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/partner_provider.dart';
import '../../api/api_service.dart';
import '../../models/partner.dart';

class PartnerLocatorScreen extends StatefulWidget {
  const PartnerLocatorScreen({super.key});
  @override
  State<PartnerLocatorScreen> createState() => _PartnerLocatorScreenState();
}

class _PartnerLocatorScreenState extends State<PartnerLocatorScreen> {
  Position? _currentPosition;
  bool _locationLoading = false;
  bool _searchingNearby = false;
  String _selectedScheme = 'MFS';
  String? _locationError;
  List<Partner> _allPartners = [];
  List<Partner> _nearbyPartners = [];
  bool _showingNearby = false;

  final Map<String, String> _schemeOptions = {
    'MFS': 'Micro Finance (MFS)',
    'TL': 'Term Loan (TL)',
    'ELS': 'Education Loan (ELS)',
    'AMY': 'Aajeevika (AMY)',
  };

  @override
  void initState() {
    super.initState();
    _loadAllPartners();
    _getCurrentLocation();
  }

  Future<void> _loadAllPartners() async {
    try {
      final response = await ApiService.getAllPartners();
      if (response['success'] == true) {
        final list = (response['partners'] as List).map((p) => Partner.fromJson(p)).toList();
        setState(() => _allPartners = list);
      }
    } catch (e) {
      // ignore
    }
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
    } catch (e) {
      setState(() {
        _locationError = 'Could not detect location';
        _locationLoading = false;
      });
    }
  }

  Future<void> _searchNearby() async {
    if (_currentPosition == null) return;
    setState(() => _searchingNearby = true);
    try {
      final result = await ApiService.findPartners(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _selectedScheme,
      );
      setState(() {
        _nearbyPartners = result.map((p) => Partner.fromJson(p)).toList();
        _showingNearby = true;
        _searchingNearby = false;
      });
    } catch (e) {
      setState(() { _searchingNearby = false; });
    }
  }

  void _showAllPartners() {
    setState(() {
      _showingNearby = false;
      _nearbyPartners = [];
    });
  }

  List<Partner> get _displayPartners => _showingNearby ? _nearbyPartners : _allPartners;

  @override
  Widget build(BuildContext context) {
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
                            : (_locationError ?? 'Detecting location...'),
                        style: TextStyle(fontSize: 13, color: _locationError != null ? Colors.orange : null),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.my_location, size: 20),
                      onPressed: _getCurrentLocation,
                    ),
                  ],
                ),

                // Find Nearby / Show All buttons
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (_currentPosition != null && !_showingNearby)
                      ElevatedButton.icon(
                        onPressed: _searchingNearby ? null : _searchNearby,
                        icon: _searchingNearby
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.near_me, size: 16),
                        label: const Text('Find Nearby'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    if (_showingNearby) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${_nearbyPartners.length} nearby',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green[700])),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _showAllPartners,
                        child: const Text('Show All', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    if (!_showingNearby)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text('${_allPartners.length} partners total',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Scheme filter (only shown when nearby)
          if (_showingNearby)
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
            child: _allPartners.isEmpty && !_showingNearby
                ? const Center(child: CircularProgressIndicator())
                : _displayPartners.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_off, size: 48, color: Colors.grey[300]),
                            const SizedBox(height: 12),
                            Text('No partners found nearby', style: TextStyle(color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            TextButton(onPressed: _showAllPartners, child: const Text('Show all partners')),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _displayPartners.length,
                        itemBuilder: (context, index) {
                          final partner = _displayPartners[index];
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
                                      if (partner.distance != null && partner.distance! > 0)
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
