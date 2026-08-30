import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/scheme_provider.dart';
import '../../models/scheme.dart';

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

    return SafeArea(
      child: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'SCA', 'PSB', 'RRB', 'NBFC-MFI'].map((type) {
                  final selected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedType = type),
                      selectedColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Scheme list
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final scheme = filtered[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _showSchemeDetails(context, scheme),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: _schemeColor(scheme.code).withOpacity(0.1),
                                      child: Icon(_schemeIcon(scheme.code), color: _schemeColor(scheme.code), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(scheme.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Text(scheme.code, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(scheme.rateFormatted, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (scheme.description != null)
                                  Text(scheme.description!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _InfoChip(label: 'Up to ${scheme.maxLoanFormatted}'),
                                    const SizedBox(width: 8),
                                    _InfoChip(label: scheme.tenureFormatted),
                                    const SizedBox(width: 8),
                                    _InfoChip(label: '${scheme.moratoriumMonths}mo moratorium'),
                                  ],
                                ),
                              ],
                            ),
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

  void _showSchemeDetails(BuildContext context, Scheme scheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(scheme.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Code: ${scheme.code}', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 20),
            if (scheme.description != null) Text(scheme.description!),
            const SizedBox(height: 20),
            _DetailRow(label: 'Max Loan Amount', value: scheme.maxLoanFormatted),
            _DetailRow(label: 'Interest Rate', value: scheme.rateFormatted),
            _DetailRow(label: 'Max Tenure', value: scheme.tenureFormatted),
            _DetailRow(label: 'Moratorium Period', value: scheme.moratoriumFormatted),
            _DetailRow(label: 'Project Cost Range', value: '${scheme.maxCostFormatted}'),
            const SizedBox(height: 16),
            const Text('Supported Channels', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: scheme.channelTypes.map((ch) => Chip(label: Text(ch, style: const TextStyle(fontSize: 12)))).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _schemeColor(String code) {
    switch (code) {
      case 'MFS': return Colors.green;
      case 'TL': return Colors.blue;
      case 'ELS': return Colors.purple;
      case 'AMY': return Colors.orange;
      default: return Colors.grey;
    }
  }

  IconData _schemeIcon(String code) {
    switch (code) {
      case 'MFS': return Icons.account_balance_wallet;
      case 'TL': return Icons.business;
      case 'ELS': return Icons.school;
      case 'AMY': return Icons.store;
      default: return Icons.help_outline;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label, value;
  const _DetailRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
