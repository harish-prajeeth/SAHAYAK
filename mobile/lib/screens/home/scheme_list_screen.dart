import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scheme_provider.dart';
import '../../models/scheme.dart';
import '../../utils/theme.dart';
import '../../widgets/common/glass_card.dart';

class SchemeListScreen extends StatefulWidget {
  const SchemeListScreen({super.key});
  @override
  State<SchemeListScreen> createState() => _SchemeListScreenState();
}

class _SchemeListScreenState extends State<SchemeListScreen> {
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SchemeProvider>(context, listen: false);
    if (provider.schemes.isEmpty) provider.loadSchemes();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SchemeProvider>(context);
    final schemes = provider.schemes.map((s) => Scheme.fromJson(s)).toList();
    final filtered = _selectedType == 'All'
        ? schemes
        : schemes.where((s) => s.channelTypes.contains(_selectedType)).toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF101836), AppColors.bg],
          stops: [0.0, 0.35],
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
                  const Text('Schemes',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text('${filtered.length} schemes available for you',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),

            // ---- Filter chips ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'SCA', 'PSB', 'RRB', 'NBFC-MFI'].map((type) {
                    final selected = _selectedType == type;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: selected
                                ? AppGradients.of(AppGradients.blue)
                                : null,
                            color: selected ? null : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: selected
                                    ? Colors.transparent
                                    : AppColors.border),
                            boxShadow: selected
                                ? [
                                    BoxShadow(
                                      color: AppColors.royal.withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(type,
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textSecondary)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // ---- Scheme list ----
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.blue))
                  : RefreshIndicator(
                      color: AppColors.blue,
                      onRefresh: () => provider.loadSchemes(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final scheme = filtered[index];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            onTap: () => _showSchemeDetails(context, scheme),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GradientIconBadge(
                                        icon: _schemeIcon(scheme.code),
                                        colors: _schemeColors(scheme.code),
                                        size: 42),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(scheme.name,
                                              style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15)),
                                          Text(scheme.code,
                                              style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color: AppColors.textMuted,
                                                  letterSpacing: 0.5)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        gradient: AppGradients
                                            .of(AppGradients.green),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(scheme.rateFormatted,
                                          style: const TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                                if (scheme.description != null) ...[
                                  const SizedBox(height: 10),
                                  Text(scheme.description!,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          color: AppColors.textSecondary,
                                          height: 1.4)),
                                ],
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _InfoChip(
                                        label:
                                            'Up to ${scheme.maxLoanFormatted}',
                                        icon: Icons.payments_rounded),
                                    _InfoChip(
                                        label: scheme.tenureFormatted,
                                        icon: Icons.schedule_rounded),
                                    _InfoChip(
                                        label:
                                            '${scheme.moratoriumMonths}mo moratorium',
                                        icon: Icons.pause_circle_rounded),
                                  ],
                                ),
                              ],
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

  void _showSchemeDetails(BuildContext context, Scheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                GradientIconBadge(
                    icon: _schemeIcon(scheme.code),
                    colors: _schemeColors(scheme.code),
                    size: 48),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scheme.name,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 20)),
                      Text('Code: ${scheme.code}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 12.5)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (scheme.description != null)
              Text(scheme.description!,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.5,
                      height: 1.5)),
            const SizedBox(height: 18),
            _DetailRow(
                label: 'Max Loan Amount', value: scheme.maxLoanFormatted),
            _DetailRow(label: 'Interest Rate', value: scheme.rateFormatted),
            _DetailRow(label: 'Max Tenure', value: scheme.tenureFormatted),
            _DetailRow(
                label: 'Moratorium Period', value: scheme.moratoriumFormatted),
            _DetailRow(
                label: 'Project Cost Range', value: '${scheme.maxCostFormatted}'),
            const SizedBox(height: 16),
            const Text('Supported Channels',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: scheme.channelTypes
                  .map((ch) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppColors.blue.withOpacity(0.3)),
                        ),
                        child: Text(ch,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blue)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Color> _schemeColors(String code) {
    switch (code) {
      case 'MFS':
        return AppGradients.green;
      case 'TL':
        return AppGradients.blue;
      case 'ELS':
        return AppGradients.purple;
      case 'AMY':
        return AppGradients.orange;
      default:
        return AppGradients.cyan;
    }
  }

  IconData _schemeIcon(String code) {
    switch (code) {
      case 'MFS':
        return Icons.account_balance_wallet_rounded;
      case 'TL':
        return Icons.business_rounded;
      case 'ELS':
        return Icons.school_rounded;
      case 'AMY':
        return Icons.store_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _InfoChip({required this.label, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 10.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
