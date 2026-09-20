import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/partner_provider.dart';
import '../../api/api_service.dart';
import '../../models/partner.dart';
import '../../utils/theme.dart';
import '../../utils/animations.dart';
import '../../widgets/common/glass_card.dart';

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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101836), AppColors.bg],
          stops: [0.0, 0.3],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ---- Header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Partners',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    _showingNearby
                        ? '${_nearbyPartners.length} partners near you'
                        : '${_allPartners.length} partners across India',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),

            // ---- Location card ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: GlassCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const GradientIconBadge(
                            icon: Icons.my_location_rounded,
                            colors: AppGradients.blue,
                            size: 34),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _locationLoading
                              ? const Row(
                                  children: [
                                    SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: AppColors.blue)),
                                    SizedBox(width: 8),
                                    Text('Detecting location...',
                                        style: TextStyle(
                                            fontSize: 12.5,
                                            color: AppColors.textSecondary)),
                                  ],
                                )
                              : Text(
                                  _currentPosition != null
                                      ? '📍 ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}'
                                      : (_locationError ?? 'Location unavailable'),
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: _locationError != null
                                          ? AppColors.orange
                                          : AppColors.textPrimary),
                                ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh_rounded,
                              size: 20, color: AppColors.textSecondary),
                          onPressed: _getCurrentLocation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (_currentPosition != null && !_showingNearby)
                          Expanded(
                            child: GradientButton(
                              label: 'Find Nearby',
                              icon: Icons.near_me_rounded,
                              height: 40,
                              colors: AppGradients.blue,
                              loading: _searchingNearby,
                              onPressed: _searchingNearby ? null : _searchNearby,
                            ),
                          ),
                        if (_showingNearby) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.green.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.green.withOpacity(0.35)),
                            ),
                            child: Text('${_nearbyPartners.length} nearby',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.green)),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _showAllPartners,
                            child: const Text('Show All',
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blue)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ---- Scheme filter (nearby mode) ----
            if (_showingNearby)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Scheme: ',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 13)),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedScheme,
                            isExpanded: true,
                            dropdownColor: AppColors.surface,
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 13),
                            icon: const Icon(Icons.expand_more_rounded,
                                color: AppColors.textMuted),
                            items: _schemeOptions.entries
                                .map((e) => DropdownMenuItem(
                                    value: e.key, child: Text(e.value)))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedScheme = v);
                                _searchNearby();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ---- Partner list ----
            Expanded(
              child: _allPartners.isEmpty && !_showingNearby
                  ? const SkeletonList(count: 5, itemHeight: 168)
                  : _displayPartners.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_off_rounded,
                                  size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                              const SizedBox(height: 12),
                              const Text('No partners found nearby',
                                  style: TextStyle(color: AppColors.textSecondary)),
                              const SizedBox(height: 8),
                              TextButton(
                                  onPressed: _showAllPartners,
                                  child: const Text('Show all partners',
                                      style: TextStyle(color: AppColors.blue))),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.blue,
                          onRefresh: () async {
                            await _loadAllPartners();
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                            itemCount: _displayPartners.length,
                            itemBuilder: (context, index) {
                              final partner = _displayPartners[index];
                              return StaggerIn(
                                index: index,
                                child: GlassCard(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GradientIconBadge(
                                            icon: _typeIcon(partner.type),
                                            colors: _typeColors(partner.type),
                                            size: 40),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(partner.name,
                                                  style: const TextStyle(
                                                      color: AppColors.textPrimary,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14.5),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis),
                                              Text(partner.typeLabel,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textMuted)),
                                            ],
                                          ),
                                        ),
                                        if (partner.distance != null &&
                                            partner.distance! > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 9, vertical: 4),
                                            decoration: BoxDecoration(
                                              gradient: AppGradients
                                                  .of(AppGradients.blue),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(partner.distanceFormatted,
                                                style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w800,
                                                    color: Colors.white)),
                                          ),
                                      ],
                                    ),
                                    if (partner.address != null) ...[
                                      const SizedBox(height: 10),
                                      Row(children: [
                                        const Icon(Icons.place_rounded,
                                            size: 14, color: AppColors.textMuted),
                                        const SizedBox(width: 6),
                                        Expanded(
                                            child: Text(partner.address!,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary))),
                                      ]),
                                    ],
                                    if (partner.phone != null) ...[
                                      const SizedBox(height: 5),
                                      Row(children: [
                                        const Icon(Icons.phone_rounded,
                                            size: 14, color: AppColors.textMuted),
                                        const SizedBox(width: 6),
                                        Text(partner.phone!,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary)),
                                      ]),
                                    ],
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        _StatusBadge(
                                            label:
                                                'Fund: ${partner.fundUtilization.toStringAsFixed(0)}%',
                                            good:
                                                partner.fundUtilization >= 80),
                                        _StatusBadge(
                                            label:
                                                'NPA: ${partner.npaRate.toStringAsFixed(1)}%',
                                            good: partner.npaRate < 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: partner.isEligible
                                                ? AppColors.green
                                                    .withOpacity(0.12)
                                                : AppColors.red
                                                    .withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: partner.isEligible
                                                    ? AppColors.green
                                                        .withOpacity(0.35)
                                                    : AppColors.red
                                                        .withOpacity(0.35)),
                                          ),
                                          child: Text(
                                            partner.isEligible
                                                ? '✅ Eligible'
                                                : '❌ Not Eligible',
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: partner.isEligible
                                                    ? AppColors.green
                                                    : AppColors.red),
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
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _typeColors(String? type) {
    switch (type) {
      case 'SCA':
        return AppGradients.blue;
      case 'PSB':
        return AppGradients.green;
      case 'RRB':
        return AppGradients.orange;
      case 'NBFC-MFI':
        return AppGradients.purple;
      default:
        return AppGradients.cyan;
    }
  }

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'SCA':
        return Icons.account_balance_rounded;
      case 'PSB':
        return Icons.savings_rounded;
      case 'RRB':
        return Icons.agriculture_rounded;
      case 'NBFC-MFI':
        return Icons.storefront_rounded;
      default:
        return Icons.business_center_rounded;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final bool good;
  const _StatusBadge({required this.label, required this.good});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: good
            ? AppColors.green.withOpacity(0.12)
            : AppColors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: good
                ? AppColors.green.withOpacity(0.35)
                : AppColors.orange.withOpacity(0.35)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: good ? AppColors.green : AppColors.orange)),
    );
  }
}
